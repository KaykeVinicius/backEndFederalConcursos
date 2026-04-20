module Api
  module V1
    module Aluno
      class LessonsController < ApplicationController
        before_action :require_aluno!

        # GET /api/v1/aluno/lessons?topic_id=X
        def index
          topic   = Topic.find(params[:topic_id])
          subject = topic.subject
          course  = subject.course

          return render json: { error: "Aluno não encontrado" }, status: :forbidden if current_student_ids.empty?

          enrollment = Enrollment.find_by(student_id: current_student_ids, course_id: course.id, status: "active")
          unless enrollment
            return render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden
          end

          lessons = topic.lessons.includes(:lesson_pdfs).ordered

          # Acesso ao vídeo depende da modalidade da matrícula do aluno
          # Presencial → apenas materiais (sem vídeo)
          # Online / Híbrido → vídeo + materiais
          can_watch_video = enrollment.online? || enrollment.hibrido?

          render json: lessons.map { |l|
            {
              id:             l.id,
              title:          l.title,
              duration:       l.duration,
              position:       l.position,
              available:      l.available,
              topic_id:       l.topic_id,
              has_video:      can_watch_video && l.youtube_id.present?,
              # youtube_id NÃO é retornado aqui — buscado individualmente via /video_token
              lesson_pdfs: l.lesson_pdfs.map { |p|
                url = p.file.attached? \
                  ? Rails.application.routes.url_helpers.rails_blob_url(p.file, host: Rails.env.development? ? ENV.fetch("RAILS_HOST_POC", "http://localhost:3003") : ENV.fetch("RAILS_HOST", "http://localhost:3001")) \
                  : p.file_url
                { id: p.id, name: p.name, file_size: p.file_size, file_url: url }
              }
            }
          }
        end
      end
    end
  end
end
