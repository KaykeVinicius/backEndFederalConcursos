module Api
  module V1
    module Aluno
      class LessonPdfsController < ApplicationController
        include PdfProtector
        before_action :require_aluno!

        def download
          @lesson_pdf = LessonPdf.find(params[:id])

          lesson  = @lesson_pdf.lesson
          topic   = lesson.topic
          subject = topic.subject
          course  = subject.course

          if current_student_ids.empty?
            return render json: { error: "Aluno não encontrado" }, status: :forbidden
          end

          unless Enrollment.exists?(student_id: current_student_ids, course_id: course.id, status: "active")
            return render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden
          end

          unless @lesson_pdf.file.attached?
            return render json: { error: "Arquivo não disponível" }, status: :not_found
          end

          original = Tempfile.new(["pdf_original", ".pdf"], binmode: true)
          original.write(@lesson_pdf.file.download)
          original.rewind

          protected_pdf = build_protected_pdf(
            original_path: original.path,
            student_name:  current_user.name,
            student_cpf:   current_student.cpf
          )

          filename = @lesson_pdf.name.end_with?(".pdf") ? @lesson_pdf.name : "#{@lesson_pdf.name}.pdf"

          send_data protected_pdf.read,
            filename:    filename,
            type:        "application/pdf",
            disposition: "inline"
        ensure
          original&.close!
          protected_pdf&.close!
        end
      end
    end
  end
end
