module Api
  module V1
    module Aluno
      class MaterialsController < ApplicationController
        include PdfProtector
        before_action :require_aluno!

        # GET /api/v1/aluno/materials?course_id=X
        def index
          course_id = params[:course_id]
          unless course_id
            return render json: { error: "course_id obrigatório" }, status: :unprocessable_entity
          end

          student_ids = Student.where(user_id: current_user.id).pluck(:id)
          if student_ids.empty?
            return render json: { error: "Aluno não encontrado" }, status: :forbidden
          end

          enrollment = Enrollment.find_by(student_id: student_ids, course_id: course_id, status: :active)
          unless enrollment
            return render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden
          end

          subject_ids = Subject.where(course_id: course_id).pluck(:id)

          materials = Material.where(subject_id: subject_ids)
                              .includes(:professor, :subject)
                              .order(created_at: :asc)

          # Se a matrícula tiver turma, filtra por turma (ou sem turma definida)
          if enrollment.turma_id
            materials = materials.where(turma_id: [enrollment.turma_id, nil])
          end

          render json: materials, each_serializer: MaterialSerializer
        end

        # GET /api/v1/aluno/materials/:id/download
        def download
          material = Material.find(params[:id])

          unless material.material_type == "pdf"
            return render json: { error: "Apenas materiais PDF suportam download protegido" }, status: :unprocessable_entity
          end

          student_ids = Student.where(user_id: current_user.id).pluck(:id)
          if student_ids.empty?
            return render json: { error: "Aluno não encontrado" }, status: :forbidden
          end

          course_id = material.subject&.course_id
          unless course_id && Enrollment.exists?(student_id: student_ids, course_id: course_id, status: "active")
            return render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden
          end

          unless material.file.attached?
            return render json: { error: "Arquivo não disponível" }, status: :not_found
          end

          student = Student.find_by(id: student_ids)

          original = Tempfile.new(["pdf_original", ".pdf"], binmode: true)
          original.write(material.file.download)
          original.rewind

          protected_pdf = build_protected_pdf(
            original_path: original.path,
            student_name:  current_user.name,
            student_cpf:   student.cpf
          )

          filename = material.title.end_with?(".pdf") ? material.title : "#{material.title}.pdf"

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
