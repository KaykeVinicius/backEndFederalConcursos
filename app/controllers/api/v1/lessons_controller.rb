module Api
  module V1
    class LessonsController < ApplicationController
      before_action :set_lesson, only: [:show, :update, :destroy]

      def index
        @lessons = if params[:topic_id]
          Lesson.where(topic_id: params[:topic_id]).includes(:lesson_pdfs).ordered
        else
          Lesson.includes(:lesson_pdfs).ordered
        end
        render json: @lessons, each_serializer: LessonSerializer
      end

      def show
        render json: @lesson, serializer: LessonSerializer
      end

      def create
        @lesson = Lesson.new(lesson_params)
        if @lesson.save
          render json: @lesson, serializer: LessonSerializer, status: :created
        else
          render json: { errors: @lesson.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @lesson.update(lesson_params)
          render json: @lesson, serializer: LessonSerializer
        else
          render json: { errors: @lesson.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @lesson.destroy
        head :no_content
      end

      private

      def set_lesson
        @lesson = Lesson.find(params[:id])
      end

      def lesson_params
        params.permit(:topic_id, :title, :duration, :youtube_id, :position, :available)
      end
    end
  end
end