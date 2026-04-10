module Api
  module V1
    class TurmaClassDaysController < ApplicationController
      before_action :set_turma

      # GET /api/v1/turmas/:turma_id/class_days
      def index
        days = @turma.turma_class_days.ordered.includes(subject: :professor)
        render json: days, each_serializer: TurmaClassDaySerializer
      end

      # POST /api/v1/turmas/:turma_id/class_days
      def create
        require_role!(:ceo, :diretor, :equipe_pedagogica)
        day = @turma.turma_class_days.new(class_day_params)
        if day.save
          render json: day, serializer: TurmaClassDaySerializer, status: :created
        else
          render json: { errors: day.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/turmas/:turma_id/class_days/:id
      def update
        require_role!(:ceo, :diretor, :equipe_pedagogica)
        day = @turma.turma_class_days.find(params[:id])
        if day.update(class_day_params)
          render json: day, serializer: TurmaClassDaySerializer
        else
          render json: { errors: day.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/turmas/:turma_id/class_days/:id
      def destroy
        require_role!(:ceo, :diretor, :equipe_pedagogica)
        day = @turma.turma_class_days.find(params[:id])
        day.destroy
        head :no_content
      end

      private

      def set_turma
        @turma = Turma.find(params[:turma_id])
      end

      def class_day_params
        params.permit(:subject_id, :date, :title, :description)
      end
    end
  end
end
