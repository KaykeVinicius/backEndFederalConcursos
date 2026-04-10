module Api
  module V1
    class SubjectsController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_subject, only: [:show, :update, :destroy]
      before_action(only: [:create, :update, :destroy]) { require_role!(:ceo, :diretor, :equipe_pedagogica) }

      # GET /subjects                    → todas (templates sem course_id)
      # GET /courses/:course_id/subjects → matérias do curso
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

      # POST /courses/:course_id/subjects → cria matéria para o curso (com nome do template)
      # POST /subjects                    → cria template global (sem course_id)
      def create
        if params[:course_id]
          @subject = Subject.new(
            course_id:    params[:course_id],
            name:         params[:name],
            description:  params[:description],
            professor_id: params[:professor_id],
            position:     Subject.where(course_id: params[:course_id]).count + 1
          )
        else
          @subject = Subject.new(subject_params)
        end

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
