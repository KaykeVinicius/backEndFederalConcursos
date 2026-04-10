module Api
  module V1
    module Aluno
      class MaterialsController < ApplicationController
        before_action :require_aluno!

        # GET /api/v1/aluno/materials?course_id=X
        def index
          course_id = params[:course_id]
          unless course_id
            return render json: { error: "course_id obrigatório" }, status: :unprocessable_entity
          end

          student = current_user.student
          unless student
            return render json: { error: "Aluno não encontrado" }, status: :forbidden
          end

          enrollment = Enrollment.find_by(student_id: student.id, course_id: course_id, status: :active)
          unless enrollment
            return render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden
          end

          subject_ids = Subject.where(course_id: course_id).pluck(:id)

          materials = Material.where(subject_id: subject_ids)
                              .includes(:professor, :subject)
                              .order(created_at: :desc)

          # Se a matrícula tiver turma, filtra por turma (ou sem turma definida)
          if enrollment.turma_id
            materials = materials.where(turma_id: [enrollment.turma_id, nil])
          end

          render json: materials, each_serializer: MaterialSerializer
        end
      end
    end
  end
end
