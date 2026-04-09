module Api
  module V1
    class StudentsController < ApplicationController
      before_action -> { require_role!(:ceo, :diretor, :equipe_pedagogica, :assistente_comercial) }
      before_action :set_student, only: [:show, :update, :destroy]

      def index
        @students = Student.includes(:user, :city).order(:name)
        render json: @students, each_serializer: StudentSerializer
      end

      def show
        render json: @student, serializer: StudentSerializer
      end

      def create
        @student = Student.new(student_params)
        resolve_city(@student)
        if @student.save
          render json: @student, serializer: StudentSerializer, status: :created
        else
          render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
        end
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
