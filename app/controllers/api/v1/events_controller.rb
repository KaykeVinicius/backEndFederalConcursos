module Api
  module V1
    class EventsController < ApplicationController
      before_action :set_event, only: [:show, :update, :destroy]

      def index
        scope = params[:course_id] ? Event.where(course_id: params[:course_id]) : Event.all
        q = scope.ransack(params[:q])
        q.sorts = "date asc" if q.sorts.empty?
        @events = q.result(distinct: true)
        render json: @events, each_serializer: EventSerializer
      end

      def show
        render json: @event, serializer: EventSerializer
      end

      def create
        @event = Event.new(event_params)
        if @event.save
          type_label = @event.aulao? ? "Aulão" : "Simulado"
          date_br    = @event.date.strftime("%d/%m/%Y")
          Notification.broadcast(
            notifiable:      @event,
            title:           "Novo #{type_label}: #{@event.title}",
            body:            "#{date_br}#{@event.location ? " — #{@event.location}" : ""}",
            except_user_id:  current_user.id
          )
          render json: @event, serializer: EventSerializer, status: :created
        else
          render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @event.update(event_params)
          render json: @event, serializer: EventSerializer
        else
          render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @event.destroy
        head :no_content
      end

      private

      def set_event
        @event = Event.find(params[:id])
      end

      def event_params
        params.permit(:title, :description, :event_type, :date, :start_time,
                      :end_time, :location, :course_id, :max_participants, :status, :is_free, :price)
      end
    end
  end
end