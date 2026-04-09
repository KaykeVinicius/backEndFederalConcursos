module Api
  module V1
    class EnrollmentsController < ApplicationController
      before_action :set_enrollment, only: [:show, :update]
      before_action { require_role!(:ceo, :diretor, :assistente_comercial) }

      def index
        @enrollments = Enrollment.includes(:student, :course, :turma).order(created_at: :desc)
        render json: @enrollments, each_serializer: EnrollmentSerializer
      end

      def show
        render json: @enrollment, serializer: EnrollmentSerializer
      end

      def create
        @enrollment = Enrollment.new(enrollment_params)
        if @enrollment.save
          render json: @enrollment, serializer: EnrollmentSerializer, status: :created
        else
          render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
        end
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