module Api
  module V1
    module Aluno
      class EventRegistrationsController < ApplicationController
        before_action :require_aluno!

        def index
          return render json: [], status: :ok if current_student_ids.empty?

          registrations = EventRegistration.where(student_id: current_student_ids)
                                           .includes(:event, :event_lote)
          render json: registrations, each_serializer: EventRegistrationSerializer
        end
      end
    end
  end
end
