module Api
  module V1
    class CoursesController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_course, only: [:show, :update, :destroy]
      before_action(only: [:create, :update, :destroy]) { require_role!(:ceo, :diretor, :equipe_pedagogica) }

      def index
        q = Course.ransack(params[:q])
        q.sorts = "title asc" if q.sorts.empty?
        @courses = q.result(distinct: true)
        render json: @courses, each_serializer: CourseSerializer
      end

      def show
        render json: @course, serializer: CourseSerializer
      end

      def create
        @course = Course.new(course_params)
        if @course.save
          Notification.broadcast(
            notifiable:      @course,
            title:           "Novo Curso: #{@course.title}",
            body:            @course.description&.truncate(80),
            except_user_id:  current_user&.id
          )
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
        if @course.destroy
          head :no_content
        else
          render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_course
        @course = Course.find(params[:id])
      end

      def course_params
        p = params.permit(:title, :description, :price, :status, :access_type,
                          :duration_in_days, :start_date, :end_date, :career_id,
                          :online_url, :workload_hours, :cover_image)
        p[:cover_image] = params[:cover_image] if params[:cover_image].present?
        p
      end
    end
  end
end