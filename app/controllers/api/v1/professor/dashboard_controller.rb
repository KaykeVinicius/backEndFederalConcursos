module Api
  module V1
    module Professor
      class DashboardController < ApplicationController
        before_action :require_professor!

        def index
          professor = current_user
          subjects  = Subject.where(professor_id: professor.id)

          # mesma lógica do TurmasController — vinculação direta, matéria ou dia letivo
          direto        = Turma.where(professor_id: professor.id).pluck(:id)
          course_ids    = subjects.where.not(course_id: nil).pluck(:course_id)
          via_subject   = Turma.where(course_id: course_ids).pluck(:id)
          via_class_day = TurmaClassDay.where(professor_id: professor.id).pluck(:turma_id)
          turma_ids     = (direto + via_subject + via_class_day).uniq

          turmas   = Turma.where(id: turma_ids, modalidade: %w[presencial hibrido])
          all_course_ids = (turmas.pluck(:course_id) + subjects.pluck(:course_id)).uniq.compact
          courses  = Course.where(id: all_course_ids)

          pending_questions = Question.where(professor_id: professor.id, status: :pending)

          render json: {
            turmas_count:            turmas.count,
            active_turmas_count:     turmas.where(status: %w[aberta em_andamento]).count,
            courses_count:           courses.count,
            subjects_count:          subjects.count,
            pending_questions_count: pending_questions.count,
            total_students:          turmas.sum { |t| t.enrolled_count }
          }
        end
      end
    end
  end
end