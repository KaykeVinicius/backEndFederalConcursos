module Api
  module V1
    class SubjectsController < ApplicationController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_subject, only: [:show, :update, :destroy]
      before_action(only: [:create, :update, :destroy]) { require_role!(:ceo, :diretor, :equipe_pedagogica) }

      # GET /subjects                    → todas (templates sem course_id)
      # GET /courses/:course_id/subjects → matérias do curso
      def index
        base = if params[:course_id]
          Subject.where(course_id: params[:course_id])
        else
          Subject.where(course_id: nil)
        end
        q = base.includes(:professors).ransack(params[:q])
        q.sorts = "name asc" if q.sorts.empty?
        @subjects = q.result(distinct: true)
        render json: @subjects, each_serializer: SubjectSerializer
      end

      def show
        render json: @subject, serializer: SubjectSerializer
      end

      def create
        @subject = if params[:course_id]
          Subject.new(
            course_id:   params[:course_id],
            name:        params[:name],
            description: params[:description],
            position:    Subject.where(course_id: params[:course_id]).count + 1
          )
        else
          Subject.new(subject_params)
        end

        if @subject.save
          sync_professors(@subject)
          render json: @subject, serializer: SubjectSerializer, status: :created
        else
          render json: { errors: @subject.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @subject.update(subject_params)
          sync_professors(@subject)
          render json: @subject, serializer: SubjectSerializer
        else
          render json: { errors: @subject.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @subject.course_id.present?
          return render json: { error: "Não é possível excluir esta disciplina pois ela está vinculada a um curso." }, status: :unprocessable_entity
        end
        if @subject.topics.exists?
          return render json: { error: "Não é possível excluir esta disciplina pois ela possui tópicos e aulas cadastradas." }, status: :unprocessable_entity
        end
        @subject.destroy
        head :no_content
      end

      private

      def set_subject
        @subject = Subject.includes(:professors).find(params[:id])
      end

      def subject_params
        params.permit(:course_id, :name, :description, :position)
      end

      # Syncs professors when professor_ids or professor_id is provided
      def sync_professors(subject)
        if params.key?(:professor_ids)
          ids = Array(params[:professor_ids]).map(&:to_i).uniq
          subject.professor_ids = ids
        elsif params.key?(:professor_id)
          pid = params[:professor_id]
          if pid.nil? || pid.to_s.empty?
            # Remove all professors
            subject.professor_subjects.destroy_all
          else
            pid = pid.to_i
            subject.professor_subjects.find_or_create_by!(professor_id: pid)
          end
        end
      end
    end
  end
end
