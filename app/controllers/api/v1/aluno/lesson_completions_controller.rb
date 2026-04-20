module Api
  module V1
    module Aluno
      class LessonCompletionsController < ApplicationController
        before_action :require_aluno!

        def index
          completions = LessonCompletion.where(student_id: current_student_ids).select(:id, :lesson_id)
          render json: completions.map { |c| { id: c.id, lesson_id: c.lesson_id } }
        end

        def create
          student = current_student
          lesson  = Lesson.find(params[:lesson_id])
          completion = LessonCompletion.find_or_create_by(student: student, lesson: lesson)
          render json: { id: completion.id, lesson_id: lesson.id }, status: :created
        end

        def destroy
          LessonCompletion.where(student_id: current_student_ids, id: params[:id]).destroy_all
          head :no_content
        end
      end
    end
  end
end