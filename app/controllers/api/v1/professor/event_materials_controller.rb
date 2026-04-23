module Api
  module V1
    module Professor
      class EventMaterialsController < ApplicationController
        before_action :require_professor!

        # GET /api/v1/professor/event_materials
        # Retorna aulões que têm a matéria do professor + materiais já enviados
        def index
          professor_subject_ids = current_user.subjects_taught.pluck(:id)

          # Aulões que incluem a matéria deste professor
          events = Event.aulao
                        .joins(:event_subjects)
                        .where(event_subjects: { subject_id: professor_subject_ids })
                        .where("date >= ?", Date.today - 1)
                        .order(date: :asc)
                        .distinct

          result = events.map do |event|
            subjects_in_event = event.event_subjects
                                     .where(subject_id: professor_subject_ids)
                                     .includes(:subject)

            subjects_data = subjects_in_event.map do |es|
              material = event.event_materials
                              .find_by(subject_id: es.subject_id, professor_id: current_user.id)
              {
                subject_id:   es.subject_id,
                subject_name: es.subject&.name,
                material:     material ? EventMaterialSerializer.new(material).as_json : nil
              }
            end

            {
              id:          event.id,
              title:       event.title,
              date:        event.date,
              start_time:  event.start_time,
              end_time:    event.end_time,
              location:    event.location,
              subjects:    subjects_data
            }
          end

          render json: result
        end

        # POST /api/v1/professor/event_materials
        def create
          event   = Event.find(params[:event_id])
          subject = current_user.subjects_taught.find(params[:subject_id])

          # Garante que a matéria está vinculada ao evento
          unless event.event_subjects.exists?(subject_id: subject.id)
            return render json: { error: "Esta matéria não está neste aulão." }, status: :unprocessable_entity
          end

          material = EventMaterial.find_or_initialize_by(
            event_id:     event.id,
            subject_id:   subject.id,
            professor_id: current_user.id
          )
          material.title = params[:title].presence || subject.name

          if params[:file].present?
            material.file.attach(params[:file])
            size = params[:file].size
            material.file_size = size < 1_048_576 ? "#{(size / 1024.0).round(1)} KB" : "#{(size / 1_048_576.0).round(1)} MB"
          end

          if material.save
            render json: material, serializer: EventMaterialSerializer, status: :created
          else
            render json: { errors: material.errors.full_messages }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/professor/event_materials/:id
        def destroy
          material = EventMaterial.where(professor_id: current_user.id).find(params[:id])
          material.destroy
          head :no_content
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Material não encontrado." }, status: :not_found
        end
      end
    end
  end
end
