module Api
  module V1
    module Aluno
      class DashboardController < ApplicationController
        before_action :require_aluno!

        def index
          student = current_user.student
          return render json: { error: "Aluno não encontrado" }, status: :not_found unless student

          enrollments     = student.enrollments.includes(:course, :turma).where(status: :active)
          completed_count = student.lesson_completions.count
          pending_questions = student.questions.where(status: :pending).count
          upcoming_events = Event.where(status: :agendado)
                                 .where(course_id: enrollments.pluck(:course_id))
                                 .order(:date).limit(5)

          render json: {
            student:            StudentSerializer.new(student).as_json,
            active_enrollments: enrollments.count,
            lessons_completed:  completed_count,
            pending_questions:  pending_questions,
            upcoming_events:    upcoming_events.map { |e| EventSerializer.new(e).as_json },
            enrollments:        enrollments.map { |e| EnrollmentSerializer.new(e).as_json }
          }
        end
      end
    end
  end
end