module Api
  module V1
    module Aluno
      class EventMaterialsController < ApplicationController
        before_action :require_aluno!

        # GET /api/v1/aluno/event_materials?event_id=X
        def index
          student = current_user.student
          event   = Event.find(params[:event_id])

          # Verifica se o aluno está inscrito no evento
          unless student.event_registrations.exists?(event_id: event.id)
            return render json: { error: "Você não está inscrito neste evento." }, status: :forbidden
          end

          materials = event.event_materials.available.includes(:subject, :professor)
          render json: materials, each_serializer: EventMaterialSerializer
        end
      end
    end
  end
end
