module Api
  module V1
    module Professor
      class TurmasController < ApplicationController
        before_action :require_professor!

        def index
          # Turmas vinculadas diretamente ao professor
          turma_ids_direto = Turma.where(professor_id: current_user.id).pluck(:id)

          # Turmas cujas matérias têm este professor
          subject_course_ids = Subject.where(professor_id: current_user.id)
                                      .where.not(course_id: nil)
                                      .pluck(:course_id)
          turma_ids_via_subject = Turma.where(course_id: subject_course_ids).pluck(:id)

          all_ids = (turma_ids_direto + turma_ids_via_subject).uniq

          @turmas = Turma.where(id: all_ids).includes(:course, :professor)
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