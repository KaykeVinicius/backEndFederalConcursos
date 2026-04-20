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
        return render json: { error: "WhatsApp inválido. Digite DDD + número (ex: 69912345678)." }, status: :unprocessable_entity unless phone.length.between?(10, 11)

        required = %w[name street number neighborhood postal_code city state]
        missing  = required.select { |f| params[f].blank? }
        return render json: { error: "Campos obrigatórios: #{missing.join(', ')}." }, status: :unprocessable_entity if missing.any?

        customer_data = {
          name:         params[:name].to_s.strip,
          cpf:          cpf_digits,
          email:        email,
          whatsapp:     phone,
          street:       params[:street].to_s.strip,
          number:       params[:number].to_s.strip,
          complement:   params[:complement].to_s.strip,
          neighborhood: params[:neighborhood].to_s.strip,
          postal_code:  params[:postal_code].to_s.gsub(/\D/, ""),
          city:         params[:city].to_s.strip,
          state:        params[:state].to_s.strip.upcase
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

        nupay  = NupayService.new
        result = nupay.create_payment(checkout_session: session, course: course)

        if result[:status] == 200 || result[:status] == 201
          psp_id      = result[:body]["pspReferenceId"]
          payment_url = result[:body]["paymentUrl"]
          session.update!(psp_reference_id: psp_id, payment_url: payment_url)
          render json: { payment_url: payment_url, reference_id: session.reference_id }, status: :ok
        else
          session.update!(status: "failed")
          Rails.logger.error("NuPay error: #{result.inspect}")
          render json: { error: "Erro ao iniciar pagamento. Tente novamente." }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error("Checkout error: #{e.message}")
        render json: { error: "Erro interno. Tente novamente." }, status: :internal_server_error
      end

      def check_availability
        cpf   = params[:cpf].to_s.gsub(/\D/, "")
        email = params[:email].to_s.strip.downcase

        cpf_taken   = cpf.present?   && (User.exists?(cpf: cpf)     || Student.exists?(cpf: cpf))
        email_taken = email.present? && (User.exists?(email: email)  || Student.exists?(email: email))

        render json: { cpf_taken: cpf_taken, email_taken: email_taken }
      end

      def student_lookup
        cpf = params[:cpf].to_s.gsub(/\D/, "")
        return render json: { found: false } unless cpf.length == 11

        # Tenta primeiro no histórico de checkouts concluídos (tem todos os campos)
        session = CheckoutSession
                    .where("customer_data->>'cpf' = ?", cpf)
                    .where(status: "completed")
                    .order(created_at: :desc)
                    .first

        if session
          d = session.customer_data
          return render json: {
            found:        true,
            name:         d["name"],
            email:        d["email"],
            whatsapp:     d["whatsapp"],
            postal_code:  d["postal_code"],
            street:       d["street"],
            number:       d["number"],
            complement:   d["complement"],
            neighborhood: d["neighborhood"],
            city:         d["city"],
            state:        d["state"],
          }
        end

        # Fallback: aluno cadastrado manualmente (dados básicos)
        student = Student.find_by(cpf: cpf)
        if student
          return render json: {
            found:    true,
            name:     student.name,
            email:    student.email,
            whatsapp: student.whatsapp.to_s,
          }
        end

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
