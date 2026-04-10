module Api
  module V1
    module Aluno
      class LessonPdfsController < ApplicationController
        before_action :require_aluno!

        def download
          @lesson_pdf = LessonPdf.find(params[:id])

          # Verifica se o aluno tem matrícula ativa no curso que contém essa aula
          lesson  = @lesson_pdf.lesson
          topic   = lesson.topic
          subject = topic.subject
          course  = subject.course

          student = current_user.student
          unless student
            render json: { error: "Aluno não encontrado" }, status: :forbidden and return
          end

          enrolled = Enrollment.exists?(
            student_id: student.id,
            course_id:  course.id,
            status:     "active"
          )

          unless enrolled
            render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden and return
          end

          unless @lesson_pdf.file.attached?
            render json: { error: "Arquivo não disponível" }, status: :not_found and return
          end

          # Baixa o arquivo do Active Storage para um tempfile
          original = Tempfile.new(["pdf_original", ".pdf"], binmode: true)
          original.write(@lesson_pdf.file.download)
          original.rewind

          # Senha = CPF do aluno sem pontuação (ex: 11122233444)
          password = student.cpf.gsub(/\D/, "")

          protected_pdf = Tempfile.new(["pdf_protected", ".pdf"], binmode: true)

          open_opts = { decryption_opts: { password: "" } }
          HexaPDF::Document.open(original.path, **open_opts) do |doc|
            doc.encrypt(
              owner_password: SecureRandom.hex(16),
              user_password:  password,
              permissions:    [:print, :copy_content],
              algorithm:      :arc4,
              key_length:     128
            )
            doc.write(protected_pdf.path, optimize: true)
          end

          protected_pdf.rewind
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
