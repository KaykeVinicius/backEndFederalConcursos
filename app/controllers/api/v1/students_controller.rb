module Api
  module V1
    class StudentsController < ApplicationController
      before_action -> { require_role!(:ceo, :diretor, :equipe_pedagogica, :assistente_comercial) }
      before_action :set_student, only: [:show, :update, :destroy]

      def index
        @students = Student.includes(:user).order(:name)
        render json: @students, each_serializer: StudentSerializer
      end

      def show
        render json: @student, serializer: StudentSerializer
      end

      def create
        @student = Student.new(student_params)
        if @student.save
          render json: @student, serializer: StudentSerializer, status: :created
        else
          render json: { errors: @student.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @student.update(student_params)
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
        params.permit(:name, :email, :whatsapp, :cpf, :instagram, :address, :internal, :active)
      end
    end
  end
end