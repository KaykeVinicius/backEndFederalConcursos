module Api
  module V1
    class WebhooksController < ApplicationController
      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token rescue nil

      def nupay
        data           = params.permit(:referenceId, :pspReferenceId, :timestamp, :paymentMethodType).to_h
        reference_id   = data["referenceId"]
        psp_reference  = data["pspReferenceId"]

        session = CheckoutSession.find_by(reference_id: reference_id) ||
                  CheckoutSession.find_by(merchant_order_reference: reference_id)

        return head :ok unless session
        return head :ok if session.status_completed?

        nupay  = NupayService.new
        status = nupay.get_status(psp_reference || session.psp_reference_id)

        if status.dig(:body, "status") == "COMPLETED"
          ActiveRecord::Base.transaction do
            session.update!(status: "completed", psp_reference_id: psp_reference || session.psp_reference_id)
            create_enrollment!(session)
          end
        elsif status.dig(:body, "status").in?(%w[CANCELLED ERROR])
          session.update!(status: "cancelled")
        end

        head :ok
      rescue => e
        Rails.logger.error("Webhook NuPay error: #{e.message}\n#{e.backtrace.first(5).join("\n")}")
        head :ok
      end

      private

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
            user:      user,
            name:      customer["name"],
            email:     email,
            cpf:       cpf,
            whatsapp:  customer["whatsapp"],
            street:    "#{customer['street']}, #{customer['number']} #{customer['complement']}".strip,
            internal:  false,
            active:    true
          )
        end

        started_at  = Date.today
        expires_at  = started_at + session.duration_days.days

        enrollment = Enrollment.create!(
          student:          student,
          course:           course,
          status:           :active,
          started_at:       started_at,
          expires_at:       expires_at,
          enrollment_type:  :online,
          payment_method:   "NuPay",
          total_paid_cents: session.amount_cents,
          contract_signed:  false
        )

        EnrollmentMailer.confirmation(enrollment, setup_token: setup_token).deliver_later
      rescue => e
        Rails.logger.error("EnrollmentMailer error: #{e.message}")
        raise
      end
    end
  end
end
