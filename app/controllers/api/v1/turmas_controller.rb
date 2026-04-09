module Api
  module V1
    class TurmasController < ApplicationController
      before_action :set_turma, only: [:show, :update, :destroy]
      before_action(only: [:create, :update, :destroy]) { require_role!(:ceo, :diretor, :equipe_pedagogica) }

      def index
        @turmas = if params[:course_id]
          Turma.where(course_id: params[:course_id]).includes(:course, :professor)
        else
          Turma.includes(:course, :professor)
        end
        render json: @turmas, each_serializer: TurmaSerializer
      end

      def show
        render json: @turma, serializer: TurmaSerializer
      end

      def create
        @turma = Turma.new(turma_params)
        if @turma.save
          render json: @turma, serializer: TurmaSerializer, status: :created
        else
          render json: { errors: @turma.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @turma.update(turma_params)
          render json: @turma, serializer: TurmaSerializer
        else
          render json: { errors: @turma.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @turma.destroy
        head :no_content
      end

      private

      def set_turma
        @turma = Turma.find(params[:id])
      end

      def turma_params
        params.permit(:course_id, :professor_id, :name, :shift, :start_date,
                      :end_date, :schedule, :max_students, :status, :modalidade)
      end
    end
  end
end