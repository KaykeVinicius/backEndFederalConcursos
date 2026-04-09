module Api
  module V1
    module Aluno
      class EventRegistrationsController < ApplicationController
        before_action :require_aluno!

        def index
          student = current_user.student
          return render json: [], status: :ok unless student

          registrations = student.event_registrations.includes(:event, :event_lote)
          render json: registrations, each_serializer: EventRegistrationSerializer
        end
      end
    end
  end
end
