module Api
  module V1
    class EventsController < ApplicationController
      before_action :set_event, only: [:show, :update, :destroy]

      def index
        @events = Event.order(:date)
        @events = @events.where(course_id: params[:course_id]) if params[:course_id]
        render json: @events, each_serializer: EventSerializer
      end

      def show
        render json: @event, serializer: EventSerializer
      end

      def create
        @event = Event.new(event_params)
        if @event.save
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