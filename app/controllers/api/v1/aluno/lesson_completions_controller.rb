module Api
  module V1
    module Aluno
      class LessonCompletionsController < ApplicationController
        before_action :require_aluno!

        def index
          student = current_user.student
          completed_ids = student.lesson_completions.pluck(:lesson_id)
          render json: { completed_lesson_ids: completed_ids }
        end

        def create
          student = current_user.student
          lesson  = Lesson.find(params[:lesson_id])

          completion = LessonCompletion.find_or_create_by(student: student, lesson: lesson)
          render json: { lesson_id: lesson.id, completed: true }, status: :created
        end

        def destroy
          student = current_user.student
          LessonCompletion.where(student: student, lesson_id: params[:id]).destroy_all
          head :no_content
        end
      end
    end
  end
end