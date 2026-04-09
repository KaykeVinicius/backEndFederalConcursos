module Api
  module V1
    class EventLotesController < ApplicationController
      before_action :set_event

      def index
        render json: @event.event_lotes.order(:position), each_serializer: EventLoteSerializer
      end

      def create
        lote = @event.event_lotes.build(lote_params)
        lote.position = @event.event_lotes.maximum(:position).to_i + 1 if lote.position.blank?
        if lote.save
          render json: lote, serializer: EventLoteSerializer, status: :created
        else
          render json: { errors: lote.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        lote = @event.event_lotes.find(params[:id])
        if lote.update(lote_params)
          render json: lote, serializer: EventLoteSerializer
        else
          render json: { errors: lote.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        lote = @event.event_lotes.find(params[:id])
        lote.destroy
        head :no_content
      end

      private

      def set_event
        @event = Event.find(params[:event_id])
      end

      def lote_params
        params.require(:event_lote).permit(:name, :price, :quantity, :position)
      end
    end
  end
end
