module Api
  module V1
    module Professor
      class MaterialsController < ApplicationController
        before_action :require_professor!
        before_action :set_material, only: [:show, :destroy]

        def index
          @materials = Material.where(professor_id: current_user.id)
                               .includes(:subject, :turma)
                               .order(created_at: :desc)
          render json: @materials, each_serializer: MaterialSerializer
        end

        def show
          render json: @material, serializer: MaterialSerializer
        end

        def create
          file = params[:file]
          mp   = material_params.except(:file)
          @material = Material.new(mp.merge(professor_id: current_user.id))
          @material.file.attach(file) if file.present?
          if @material.save
            render json: @material, serializer: MaterialSerializer, status: :created
          else
            render json: { errors: @material.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @material.destroy
          head :no_content
        end

        private

        def set_material
          @material = Material.where(professor_id: current_user.id).find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Material não encontrado" }, status: :not_found
        end

        def material_params
          params.permit(:title, :material_type, :subject_id, :turma_id,
                        :file_name, :file_url, :file_size, :file, :notes)
        end
      end
    end
  end
end