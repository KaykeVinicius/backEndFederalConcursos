module Api
  module V1
    module Aluno
      class LessonCompletionsController < ApplicationController
        before_action :require_aluno!

        def index
          student = current_user.student
          completions = student.lesson_completions.select(:id, :lesson_id)
          render json: completions.map { |c| { id: c.id, lesson_id: c.lesson_id } }
        end

        def create
          student = current_user.student
          lesson  = Lesson.find(params[:lesson_id])
          completion = LessonCompletion.find_or_create_by(student: student, lesson: lesson)
          render json: { id: completion.id, lesson_id: lesson.id }, status: :created
        end

        def destroy
          student = current_user.student
          LessonCompletion.where(student: student, id: params[:id]).destroy_all
          head :no_content
        end
      end
    end
  end
end