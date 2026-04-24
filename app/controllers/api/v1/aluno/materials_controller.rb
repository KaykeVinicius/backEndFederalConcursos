module Api
  module V1
    module Aluno
      class MaterialsController < ApplicationController
        include PdfProtector
        skip_before_action :authenticate_user!, only: [:download]
        before_action :require_aluno!, except: [:download]

        # GET /api/v1/aluno/materials?course_id=X
        def index
          course_id = params[:course_id]
          unless course_id
            return render json: { error: "course_id obrigatório" }, status: :unprocessable_entity
          end

          student_ids = Student.where(user_id: current_user.id).pluck(:id)
          return render json: { error: "Aluno não encontrado" }, status: :forbidden if student_ids.empty?

          enrollment = Enrollment.find_by(student_id: student_ids, course_id: course_id, status: :active)
          return render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden unless enrollment

          subject_ids = Subject.where(course_id: course_id).pluck(:id)
          turma_ids   = Turma.where(course_id: course_id).pluck(:id)

          materials = Material
            .where(subject_id: subject_ids)
            .or(Material.where(turma_id: turma_ids))
            .includes(:professor, :subject, :turma)
            .order(created_at: :asc)

          if enrollment.turma_id
            materials = materials.where(turma_id: [enrollment.turma_id, nil])
          end

          render json: materials, each_serializer: MaterialSerializer
        end

        # POST /api/v1/aluno/materials/:id/request_download
        # Gera token de uso único (60s) para download direto via URL
        def request_download
          material = resolve_material_for_current_user(params[:id])
          return if performed?

          token = SecureRandom.urlsafe_base64(32)
          Rails.cache.write(
            "dl_token:#{token}",
            { material_id: material.id, user_id: current_user.id },
            expires_in: 60.seconds
          )
          render json: { token: token, expires_in: 60 }
        end

        # GET /api/v1/aluno/materials/:id/download
        # Aceita autenticação via header JWT OU via token de uso único (?token=)
        def download
          user, material = resolve_download_auth
          return if performed?

          unless material.file.attached?
            return render json: { error: "Arquivo não disponível" }, status: :not_found
          end

          student = Student.find_by(user_id: user.id)

          original      = Tempfile.new(["pdf_original", ".pdf"], binmode: true)
          original.write(material.file.download)
          original.rewind

          protected_pdf = build_protected_pdf(
            original_path: original.path,
            student_name:  user.name,
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

        private

        def resolve_material_for_current_user(id)
          material = Material.find(id)
          unless material.material_type == "pdf"
            render json: { error: "Apenas PDFs suportam download protegido" }, status: :unprocessable_entity
            return
          end

          student_ids = Student.where(user_id: current_user.id).pluck(:id)
          if student_ids.empty?
            render json: { error: "Aluno não encontrado" }, status: :forbidden
            return
          end

          course_id = material.subject&.course_id || material.turma&.course_id
          unless course_id && Enrollment.exists?(student_id: student_ids, course_id: course_id, status: "active")
            render json: { error: "Sem matrícula ativa neste curso" }, status: :forbidden
            return
          end

          material
        end

        # Autentica via JWT header (fluxo normal) OU via token de uso único na query string (mobile)
        def resolve_download_auth
          if params[:token].present?
            cached = Rails.cache.read("dl_token:#{params[:token]}")
            unless cached && cached[:material_id] == params[:id].to_i
              render json: { error: "Token inválido ou expirado" }, status: :unauthorized
              return [nil, nil]
            end
            Rails.cache.delete("dl_token:#{params[:token]}")

            user     = User.includes(:user_type).find(cached[:user_id])
            material = Material.find(cached[:material_id])
            [user, material]
          else
            authenticate_user!
            return [nil, nil] if performed?
            require_aluno!
            return [nil, nil] if performed?
            material = resolve_material_for_current_user(params[:id])
            return [nil, nil] if performed?
            [current_user, material]
          end
        end
      end
    end
  end
end
