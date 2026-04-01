module Api
  module V1
    class CoursesController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_course, only: [:show, :update, :destroy]

      def index
        @courses = Course.order(:title)
        render json: @courses, each_serializer: CourseSerializer
      end

      def show
        render json: @course, serializer: CourseSerializer
      end

      def create
        @course = Course.new(course_params)
        if @course.save
          render json: @course, serializer: CourseSerializer, status: :created
        else
          render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @course.update(course_params)
          render json: @course, serializer: CourseSerializer
        else
          render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @course.destroy
        head :no_content
      end

      private

      def set_course
        @course = Course.find(params[:id])
      end

      def course_params
        params.permit(:title, :description, :price, :status, :access_type,
                      :duration_in_days, :start_date, :end_date, :career_id)
      end
    end
  end
end