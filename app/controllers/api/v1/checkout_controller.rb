module Api
  module V1
    class CheckoutController < ApplicationController
      skip_before_action :authenticate_user!

      def create
        course = Course.find_by(id: params[:course_id])
        return render json: { error: "Curso não encontrado." }, status: :not_found unless course
        return render json: { error: "Curso não disponível para matrícula online." }, status: :unprocessable_entity unless course.online? && course.published?

        cpf_digits = params[:cpf].to_s.gsub(/\D/, "")
        return render json: { error: "CPF inválido." }, status: :unprocessable_entity unless valid_cpf?(cpf_digits)

        email = params[:email].to_s.strip.downcase
        return render json: { error: "E-mail inválido." }, status: :unprocessable_entity unless email.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)

        phone = params[:whatsapp].to_s.gsub(/\D/, "")
        return render json: { error: "WhatsApp inválido." }, status: :unprocessable_entity unless phone.length.between?(10, 11)

        customer_data = {
          name:     params[:name].to_s.strip,
          cpf:      cpf_digits,
          email:    email,
          whatsapp: phone
        }

        session = CheckoutSession.create!(
          reference_id:             SecureRandom.uuid,
          merchant_order_reference: "FEDERAL-#{SecureRandom.hex(8).upcase}",
          course:                   course,
          amount_cents:             (course.price * 100).to_i,
          duration_days:            params[:duration_days].presence&.to_i || 365,
          customer_data:            customer_data,
          status:                   "pending"
        )

        result = StripeService.new.create_checkout_session(checkout_session: session, course: course)

        if result[:status] == 200
          session.update!(payment_url: result[:url], psp_reference_id: result[:stripe_session_id])
          render json: { payment_url: result[:url], reference_id: session.reference_id }, status: :ok
        else
          session.update!(status: "failed")
          render json: { error: "Erro ao iniciar pagamento. Tente novamente." }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error("Checkout error: #{e.message}")
        render json: { error: "Erro interno. Tente novamente." }, status: :internal_server_error
      end

      def check_availability
        cpf   = params[:cpf].to_s.gsub(/\D/, "")
        email = params[:email].to_s.strip.downcase

        cpf_taken   = cpf.present?   && (User.exists?(cpf: cpf)    || Student.exists?(cpf: cpf))
        email_taken = email.present? && (User.exists?(email: email) || Student.exists?(email: email))

        render json: { cpf_taken: cpf_taken, email_taken: email_taken }
      end

      def student_lookup
        cpf = params[:cpf].to_s.gsub(/\D/, "")
        return render json: { found: false } unless cpf.length == 11

        session = CheckoutSession
                    .where("customer_data->>'cpf' = ?", cpf)
                    .where(status: "completed")
                    .order(created_at: :desc)
                    .first

        if session
          d = session.customer_data
          return render json: { found: true, name: d["name"], email: d["email"], whatsapp: d["whatsapp"] }
        end

        student = Student.find_by(cpf: cpf)
        return render json: { found: true, name: student.name, email: student.email, whatsapp: student.whatsapp.to_s } if student

        render json: { found: false }
      end

      private

      def valid_cpf?(digits)
        return false unless digits.length == 11
        return false if digits.chars.uniq.size == 1

        [9, 10].all? do |pos|
          sum = digits[0, pos].chars.each_with_index.sum { |d, i| d.to_i * (pos + 1 - i) }
          rem = (sum * 10) % 11
          rem = 0 if rem >= 10
          rem == digits[pos].to_i
        end
      end
    end
  end
end
