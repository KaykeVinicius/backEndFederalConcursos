module Api
  module V1
    class EnrollmentsController < ApplicationController
      before_action :set_enrollment, only: [:show, :update, :resend_email]
      before_action { require_role!(:ceo, :diretor, :assistente_comercial) }

      def index
        q = Enrollment.includes(:student, :course, :turma).ransack(params[:q])
        q.sorts = "created_at desc" if q.sorts.empty?
        @enrollments = q.result(distinct: true)
        render json: @enrollments, each_serializer: EnrollmentSerializer
      end

      def show
        render json: @enrollment, serializer: EnrollmentSerializer
      end

      def create
        @enrollment = Enrollment.new(enrollment_params)

        # Bloqueia matrícula duplicada: mesmo usuário (via todos os student_ids) no mesmo curso
        if @enrollment.student_id.present? && @enrollment.course_id.present?
          student = Student.find_by(id: @enrollment.student_id)
          if student
            all_student_ids = Student.where(user_id: student.user_id).pluck(:id)
            if Enrollment.where(student_id: all_student_ids, course_id: @enrollment.course_id, status: :active).exists?
              return render json: { errors: ["Este aluno já possui uma matrícula ativa neste curso."] }, status: :unprocessable_entity
            end
          end
        end

        if @enrollment.save
          contract = create_contract(@enrollment)
          send_enrollment_email(@enrollment, contract)
          render json: @enrollment, serializer: EnrollmentSerializer, status: :created
        else
          render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def resend_email
        send_enrollment_email(@enrollment)
        render json: { message: "E-mail reenviado com sucesso." }
      rescue => e
        render json: { error: "Erro ao reenviar e-mail: #{e.message}" }, status: :unprocessable_entity
      end

      def update
        if @enrollment.update(enrollment_params)
          render json: @enrollment, serializer: EnrollmentSerializer
        else
          render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_enrollment
        @enrollment = Enrollment.find(params[:id])
      end

      def create_contract(enrollment)
        Contract.create!(
          enrollment: enrollment,
          student:    enrollment.student,
          course:     enrollment.course,
          version:    "1.0",
          status:     :pending
        )
      rescue => e
        Rails.logger.error "[EnrollmentsController] Erro ao criar contrato: #{e.message}"
        nil
      end

      def send_enrollment_email(enrollment, contract = nil)
        student = enrollment.student
        return unless student&.email.present?

        # Cria User para o aluno se ainda não existir
        user = student.user || User.find_by(email: student.email) || User.find_by(cpf: student.cpf)
        if user.nil?
          aluno_type    = UserType.find_by(slug: "aluno")
          temp_password = SecureRandom.hex(16)
          user = User.new(
            name:                  student.name,
            email:                 student.email,
            cpf:                   student.cpf,
            role:                  :aluno,
            user_type:             aluno_type,
            password:              temp_password,
            password_confirmation: temp_password,
            active:                false
          )
          user.save!(validate: false)
        end

        # Vincula user ao student se ainda não estiver vinculado
        student.update_column(:user_id, user.id) if student.user_id.nil?

        # Gera token de setup se o usuário nunca fez login (session_token nil)
        # ou ainda não ativou a conta (active: false)
        needs_setup = !user.active? || user.session_token.nil?
        setup_token = needs_setup ? user.generate_setup_token! : nil

        EnrollmentMailer.confirmation(enrollment, setup_token: setup_token, contract: contract).deliver_now
      rescue => e
        Rails.logger.error "[EnrollmentsController] Erro ao enviar e-mail: #{e.message}"
      end

      def enrollment_params
        permitted = params.permit(:student_id, :course_id, :turma_id, :career_id,
                                  :status, :started_at, :expires_at, :enrollment_type,
                                  :payment_method, :total_paid, :contract_signed)
        if permitted.key?(:total_paid)
          permitted[:total_paid_cents] = (permitted.delete(:total_paid).to_f * 100).round
        end
        permitted
      end
    end
  end
end