module Api
  module V1
    module Aluno
      class VideoTokensController < ApplicationController
        before_action :require_aluno!

        # GET /api/v1/aluno/lessons/:lesson_id/video_token
        # Retorna o ID do vídeo somente para alunos matriculados com acesso online/híbrido.
        # Chamado apenas quando o aluno vai assistir — não em listagens.
        def show
          lesson  = Lesson.find(params[:lesson_id])
          topic   = lesson.topic
          subject = topic.subject
          course  = subject.course

          student = current_user.student
          return render json: { error: "Aluno não encontrado" }, status: :forbidden unless student

          enrollment = Enrollment.find_by(
            student_id: student.id,
            course_id:  course.id,
            status:     "active"
          )

          return render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden unless enrollment
          return render json: { error: "Modalidade sem acesso a vídeo" }, status: :forbidden unless enrollment.online? || enrollment.hibrido?
          return render json: { error: "Vídeo não disponível" }, status: :not_found if lesson.youtube_id.blank?

          render json: { youtube_id: lesson.youtube_id }
        end
      end
    end
  end
end
