module Api
  module V1
    module Aluno
      class QuestionsController < ApplicationController
        before_action :require_aluno!

        def index
          @questions = Question.where(student_id: current_student_ids)
                               .includes(:professor, :lesson, :subject)
                               .order(created_at: :desc)
          render json: @questions, each_serializer: QuestionSerializer
        end

        def create
          student = current_student
          lesson  = Lesson.find(params[:lesson_id])
          subject = lesson.subject

          unless subject.professor
            render json: { error: "Esta matéria não possui professor atribuído. Entre em contato com a secretaria." }, status: :unprocessable_entity
            return
          end

          @question = Question.new(
            student:      student,
            professor:    subject.professor,
            lesson:       lesson,
            subject:      subject,
            text:         params[:text],
            video_moment: params[:video_moment]
          )

          if @question.save
            QuestionMailer.new_question(@question).deliver_later
            render json: @question, serializer: QuestionSerializer, status: :created
          else
            render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end