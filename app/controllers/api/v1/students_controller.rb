module Api
  module V1
    class StudentsController < ApplicationController
      before_action -> { require_role!(:ceo, :diretor, :equipe_pedagogica, :assistente_comercial) }
      before_action :set_student, only: [:show, :update, :destroy]

      def index
        q = Student.includes(:user, :city).ransack(params[:q])
        q.sorts = "name asc" if q.sorts.empty?
        @students = q.result(distinct: true)
        render json: @students, each_serializer: StudentSerializer
      end

      def show
        render json: @student, serializer: StudentSerializer
      end

      def create
        @student = Student.new(student_params)
        resolve_city(@student)

        ActiveRecord::Base.transaction do
          @student.save!

          # Cria o usuário aluno automaticamente se ainda não existir
          unless User.exists?(email: @student.email)
            user = User.create!(
              name:     @student.name,
              email:    @student.email,
              cpf:      @student.cpf,
              password: @student.cpf, # senha inicial = CPF
              role:     :aluno
            )
            @student.update_column(:user_id, user.id)
          end
        end

        render json: @student, serializer: StudentSerializer, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def update
        @student.assign_attributes(student_params)
        resolve_city(@student)
        if @student.save
          render json: @student, serializer: StudentSerializer
        else
          render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @student.enrollments.exists?
          return render json: { error: "Não é possível excluir este aluno pois ele possui matrículas vinculadas." }, status: :unprocessable_entity
        end
        @student.update!(active: false)
        head :no_content
      end

      private

      def set_student
        @student = Student.find(params[:id])
      end

      def student_params
        params.permit(
          :name, :email, :whatsapp, :cpf, :instagram,
          :street, :address_number, :address_complement, :neighborhood, :cep,
          :internal, :active, :situacao, :city_id
        )
      end

      # If city_name + city_state are provided, find-or-create the city and assign it
      def resolve_city(student)
        city_name  = params[:city_name].presence
        city_state = params[:city_state].presence
        ibge_code  = params[:ibge_code].presence

        return unless city_name && city_state

        city = City.find_or_initialize_by(name: city_name, state: city_state.upcase)
        city.ibge_code = ibge_code if ibge_code.present?
        city.save!
        student.city = city
      end
    end
  end
end
