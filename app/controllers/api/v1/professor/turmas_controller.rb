module Api
  module V1
    module Professor
      class TurmasController < ApplicationController
        before_action :require_professor!

        # GET /api/v1/professor/turmas
        # Retorna apenas turmas presenciais ou híbridas onde o professor está vinculado:
        #   1. professor_id direto na turma
        #   2. tem matéria cadastrada no curso da turma
        #   3. está em algum turma_class_day da turma
        def index
          ids = turmas_for_professor(current_user.id)
          @turmas = Turma.where(id: ids)
                         .where(modalidade: %w[presencial hibrido])
                         .includes(:course, :professor)
          render json: @turmas, each_serializer: TurmaSerializer
        end

        # GET /api/v1/professor/turmas/:id
        def show
          ids = turmas_for_professor(current_user.id)
          @turma = Turma.where(id: ids, modalidade: %w[presencial hibrido]).find(params[:id])
          render json: @turma, serializer: TurmaSerializer
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Acesso negado" }, status: :forbidden
        end

        # GET /api/v1/professor/turmas/:id/students
        def students
          ids = turmas_for_professor(current_user.id)
          turma = Turma.where(id: ids).find(params[:id])
          enrollments = turma.enrollments.where(status: :active).includes(:student)
          render json: enrollments.map { |e|
            s = e.student
            next unless s
            { id: s.id, name: s.name, email: s.email, whatsapp: s.whatsapp, cpf: s.cpf }
          }.compact
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Acesso negado" }, status: :forbidden
        end

        private

        def turmas_for_professor(professor_id)
          # 1. vinculado diretamente como professor da turma
          direto = Turma.where(professor_id: professor_id).pluck(:id)

          # 2. tem matéria cadastrada no curso da turma
          course_ids = Subject.where(professor_id: professor_id)
                              .where.not(course_id: nil)
                              .pluck(:course_id)
          via_subject = Turma.where(course_id: course_ids).pluck(:id)

          # 3. está em algum dia letivo da turma
          via_class_day = TurmaClassDay.where(professor_id: professor_id).pluck(:turma_id)

          (direto + via_subject + via_class_day).uniq
        end
      end
    end
  end
end
