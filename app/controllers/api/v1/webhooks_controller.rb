module Api
  module V1
    class WebhooksController < ApplicationController
      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token rescue nil

      def stripe
        payload    = request.body.read
        sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
        secret     = ENV.fetch("STRIPE_WEBHOOK_SECRET", "")

        event = Stripe::Webhook.construct_event(payload, sig_header, secret)

        case event["type"]
        when "checkout.session.completed"
          handle_checkout_completed(event["data"]["object"])
        when "checkout.session.expired"
          handle_checkout_expired(event["data"]["object"])
        when "charge.dispute.created"
          handle_dispute_created(event["data"]["object"])
        when "charge.dispute.closed"
          handle_dispute_closed(event["data"]["object"])
        when "charge.refunded"
          handle_charge_refunded(event["data"]["object"])
        end

        head :ok
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.error("Stripe webhook signature invalid: #{e.message}")
        head :bad_request
      rescue => e
        Rails.logger.error("Stripe webhook error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
        head :ok
      end

      private

      # ── Pagamento confirmado ─────────────────────────────────────────────────

      def handle_checkout_completed(stripe_session)
        reference_id = stripe_session["client_reference_id"] || stripe_session.dig("metadata", "reference_id")
        session = CheckoutSession.find_by(reference_id: reference_id) ||
                  CheckoutSession.find_by(psp_reference_id: stripe_session["id"])

        return unless session

        # with_lock garante que apenas um processo executa por vez (previne race condition
        # quando o Stripe reenvia o mesmo webhook simultaneamente)
        session.with_lock do
          return if session.status_completed?

          payment_intent_id = stripe_session["payment_intent"]

          session.update!(
            status:            "completed",
            psp_reference_id:  stripe_session["id"],
            payment_intent_id: payment_intent_id
          )
          create_enrollment!(session)
        end
      end

      # ── Sessão expirou sem pagamento ─────────────────────────────────────────

      def handle_checkout_expired(stripe_session)
        reference_id = stripe_session["client_reference_id"] || stripe_session.dig("metadata", "reference_id")
        session = CheckoutSession.find_by(reference_id: reference_id) ||
                  CheckoutSession.find_by(psp_reference_id: stripe_session["id"])

        return unless session
        return if session.status_completed?

        session.update!(status: "cancelled")
        Rails.logger.info("Checkout session #{session.reference_id} expired without payment")
      end

      # ── Chargeback aberto (cliente contestou com o banco) ────────────────────

      def handle_dispute_created(dispute)
        enrollment = find_enrollment_by_charge(dispute["charge"])
        return unless enrollment
        return if enrollment.canceled? || enrollment.suspended?

        enrollment.update!(status: :suspended)
        Rails.logger.warn("Enrollment #{enrollment.id} suspended — dispute #{dispute['id']} opened")
      end

      # ── Chargeback resolvido ─────────────────────────────────────────────────

      def handle_dispute_closed(dispute)
        enrollment = find_enrollment_by_charge(dispute["charge"])
        return unless enrollment

        case dispute["status"]
        when "won"
          # Empresa ganhou a disputa — reativa matrícula
          enrollment.update!(status: :active) unless enrollment.canceled?
          Rails.logger.info("Enrollment #{enrollment.id} reactivated — dispute #{dispute['id']} won")
        when "lost"
          # Empresa perdeu — cancela permanentemente
          enrollment.update!(status: :canceled)
          Rails.logger.warn("Enrollment #{enrollment.id} canceled — dispute #{dispute['id']} lost")
        end
      end

      # ── Reembolso total emitido ──────────────────────────────────────────────

      def handle_charge_refunded(charge)
        # charge["refunded"] só é true em reembolso total. Parcial não cancela matrícula.
        return unless charge["refunded"]

        enrollment = find_enrollment_by_charge(charge["id"])
        return unless enrollment
        return if enrollment.canceled?

        enrollment.update!(status: :canceled)
        Rails.logger.warn("Enrollment #{enrollment.id} canceled — full refund on charge #{charge['id']}")
      end

      # ── Helpers ──────────────────────────────────────────────────────────────

      def find_enrollment_by_charge(charge_id)
        return nil if charge_id.blank?

        charge            = Stripe::Charge.retrieve(charge_id)
        payment_intent_id = charge["payment_intent"]
        return nil if payment_intent_id.blank?

        session = CheckoutSession.find_by(payment_intent_id: payment_intent_id)
        return nil unless session

        cpf     = session.customer_data["cpf"].to_s.gsub(/\D/, "")
        student = Student.find_by(cpf: cpf)
        return nil unless student

        student.enrollments
               .where(course: session.course, payment_method: "stripe")
               .order(created_at: :desc)
               .first
      rescue Stripe::StripeError => e
        Rails.logger.error("Stripe error retrieving charge #{charge_id}: #{e.message}")
        nil
      end

      def create_enrollment!(session)
        course   = session.course
        customer = session.customer_data
        cpf      = customer["cpf"].to_s.gsub(/\D/, "")
        email    = customer["email"].to_s.downcase

        user = User.find_by(email: email) || User.find_by(cpf: cpf)
        setup_token = nil

        unless user
          temp_pass = SecureRandom.hex(8)
          user = User.create!(
            name:     customer["name"],
            email:    email,
            cpf:      cpf,
            password: temp_pass,
            role:     :aluno,
            active:   true
          )
          setup_token = user.generate_setup_token!
        end

        student = user.student || Student.find_by(cpf: cpf) || Student.find_by(email: email)

        unless student
          student = Student.create!(
            user:     user,
            name:     customer["name"],
            email:    email,
            cpf:      cpf,
            whatsapp: customer["whatsapp"],
            internal: false,
            active:   true
          )
        end

        # Previne dupla matrícula online: ignora matrículas presenciais/híbridas já existentes
        existing = student.enrollments
                          .where(course: course, enrollment_type: :online, payment_method: "stripe")
                          .where.not(status: :canceled)
                          .first
        if existing
          Rails.logger.warn("Duplicate enrollment prevented for student #{student.id} in course #{course.id}")
          return existing
        end

        started_at = Date.today
        expires_at = started_at + session.duration_days.days

        enrollment = Enrollment.create!(
          student:          student,
          course:           course,
          status:           :active,
          started_at:       started_at,
          expires_at:       expires_at,
          enrollment_type:  :online,
          payment_method:   "stripe",
          total_paid_cents: session.amount_cents,
          contract_signed:  false
        )

        EnrollmentMailer.confirmation(enrollment, setup_token: setup_token).deliver_later
        enrollment
      rescue => e
        Rails.logger.error("create_enrollment! error: #{e.message}")
        raise
      end
    end
  end
end
