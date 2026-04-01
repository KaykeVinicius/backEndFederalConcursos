module Api
  module V1
    module Professor
      class DashboardController < ApplicationController
        before_action :require_professor!

        def index
          professor = current_user
          turmas   = Turma.where(professor_id: professor.id)
          subjects = Subject.where(professor_id: professor.id)
          course_ids = (turmas.pluck(:course_id) + subjects.pluck(:course_id)).uniq
          courses  = Course.where(id: course_ids)
          pending_questions = Question.where(professor_id: professor.id, status: :pending)

          render json: {
            turmas_count:            turmas.count,
            active_turmas_count:     turmas.where(status: [:aberta, :em_andamento]).count,
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