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

      def handle_checkout_completed(stripe_session)
        reference_id = stripe_session["client_reference_id"] || stripe_session.dig("metadata", "reference_id")
        session = CheckoutSession.find_by(reference_id: reference_id) ||
                  CheckoutSession.find_by(psp_reference_id: stripe_session["id"])

        return unless session
        return if session.status_completed?

        ActiveRecord::Base.transaction do
          session.update!(status: "completed", psp_reference_id: stripe_session["id"])
          create_enrollment!(session)
        end
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
      rescue => e
        Rails.logger.error("create_enrollment! error: #{e.message}")
        raise
      end
    end
  end
end
