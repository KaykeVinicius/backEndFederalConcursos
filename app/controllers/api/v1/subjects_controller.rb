module Api
  module V1
    class SubjectsController < ApplicationController
      before_action :set_subject, only: [:show, :update, :destroy]

      def index
        @subjects = if params[:course_id]
          Subject.where(course_id: params[:course_id]).includes(:professor).ordered
        else
          Subject.includes(:professor).ordered
        end
        render json: @subjects, each_serializer: SubjectSerializer
      end

      def show
        render json: @subject, serializer: SubjectSerializer
      end

      def create
        @subject = Subject.new(subject_params)
        if @subject.save
          render json: @subject, serializer: SubjectSerializer, status: :created
        else
          render json: { errors: @subject.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @subject.update(subject_params)
          render json: @subject, serializer: SubjectSerializer
        else
          render json: { errors: @subject.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @subject.destroy
        head :no_content
      end

      private

      def set_subject
        @subject = Subject.find(params[:id])
      end

      def subject_params
        params.permit(:course_id, :professor_id, :name, :description, :position)
      end
    end
  end
end