module Api
  module V1
    module Professor
      class TurmasController < ApplicationController
        before_action :require_professor!

        def index
          @turmas = Turma.where(professor_id: current_user.id)
                         .includes(:course, :professor)
          render json: @turmas, each_serializer: TurmaSerializer
        end

        def show
          @turma = Turma.find(params[:id])
          unless @turma.professor_id == current_user.id
            return render json: { error: "Acesso negado" }, status: :forbidden
          end
          render json: @turma, serializer: TurmaSerializer
        end
      end
    end
  end
end