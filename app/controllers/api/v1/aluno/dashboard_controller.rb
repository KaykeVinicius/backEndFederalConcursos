module Api
  module V1
    module Aluno
      class DashboardController < ApplicationController
        before_action :require_aluno!

        def index
          # Busca todos os students vinculados ao usuário (pode haver mais de um)
          students = Student.where(user_id: current_user.id)
          return render json: { error: "Aluno não encontrado" }, status: :not_found if students.empty?

          student_ids     = students.pluck(:id)
          all_enrollments = Enrollment.includes(:course, :turma).where(student_id: student_ids, status: :active)

          # Deduplica por course_id: quando o mesmo aluno tem múltiplas matrículas no mesmo
          # curso (ex: dois registros de student para o mesmo usuário), exibe apenas uma,
          # priorizando online > hibrido > presencial.
          type_priority = { "online" => 0, "hibrido" => 1, "presencial" => 2 }
          enrollments = all_enrollments
            .sort_by { |e| type_priority[e.enrollment_type] || 99 }
            .uniq(&:course_id)

          completed_count   = LessonCompletion.where(student_id: student_ids).count
          pending_questions = Question.where(student_id: student_ids, status: :pending).count
          student           = students.first
          upcoming_events   = Event.where(status: :agendado).order(:date).limit(5)

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