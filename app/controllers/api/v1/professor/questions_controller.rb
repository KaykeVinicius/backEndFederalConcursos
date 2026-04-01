module Api
  module V1
    module Professor
      class QuestionsController < ApplicationController
        before_action :require_professor!
        before_action :set_question, only: [:show, :update, :answer]

        def index
          @questions = Question.where(professor_id: current_user.id)
                               .includes(:student, :lesson, :subject)
                               .order(created_at: :desc)
          @questions = @questions.where(status: params[:status]) if params[:status].present?
          render json: @questions, each_serializer: QuestionSerializer
        end

        def show
          render json: @question, serializer: QuestionSerializer
        end

        # PATCH /api/v1/professor/questions/:id/answer
        def answer
          if @question.answer!(params[:answer])
            render json: @question, serializer: QuestionSerializer
          else
            render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def set_question
          @question = Question.where(professor_id: current_user.id).find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Dúvida não encontrada" }, status: :not_found
        end
      end
    end
  end
end