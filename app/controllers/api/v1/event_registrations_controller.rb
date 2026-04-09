module Api
  module V1
    class EventRegistrationsController < ApplicationController
      before_action :set_event, only: [:index, :create, :destroy]

      # GET /api/v1/events/:event_id/registrations
      def index
        registrations = @event.event_registrations.includes(:student)
        render json: registrations, each_serializer: EventRegistrationSerializer
      end

      # POST /api/v1/events/:event_id/registrations
      def create
        if @event.full?
          return render json: { error: "Evento esgotado. Não há mais vagas disponíveis." }, status: :unprocessable_entity
        end

        student = Student.find(params[:student_id])

        # Atribui o lote ativo (se o evento tiver lotes)
        lote = @event.current_lote
        if lote.nil? && @event.event_lotes.any?
          return render json: { error: "Todos os lotes estão esgotados." }, status: :unprocessable_entity
        end

        registration = @event.event_registrations.build(
          student: student,
          event_lote_id: lote&.id
        )

        if registration.save
          EventMailer.ticket(registration).deliver_later
          @event.increment!(:registered_count)
          render json: registration, serializer: EventRegistrationSerializer, status: :created
        else
          render json: { errors: registration.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/event_registrations/checkin
      def checkin
        registration = EventRegistration.includes(:event, :student).find_by(ticket_token: params[:token])

        if registration.nil?
          return render json: { error: "Ingresso não encontrado." }, status: :not_found
        end

        if registration.attended?
          return render json: {
            error: "Presença já registrada.",
            registration: EventRegistrationSerializer.new(registration).as_json
          }, status: :unprocessable_entity
        end

        registration.mark_attended!
        render json: registration, serializer: EventRegistrationSerializer
      end

      # PATCH /api/v1/event_registrations/undo_checkin
      def undo_checkin
        registration = EventRegistration.includes(:event, :student).find_by(id: params[:id])
        return render json: { error: "Inscrição não encontrada." }, status: :not_found unless registration

        registration.update!(attended: false, attended_at: nil)
        render json: registration, serializer: EventRegistrationSerializer
      end

      # DELETE /api/v1/events/:event_id/registrations/:id
      def destroy
        registration = EventRegistration.find(params[:id])
        registration.destroy
        @event.decrement!(:registered_count)
        head :no_content
      end

      private

      def set_event
        @event = Event.find(params[:event_id])
      end
    end
  end
end
