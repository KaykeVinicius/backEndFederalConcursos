module Api
  module V1
    class EventSubjectsController < ApplicationController
      before_action :set_event

      # GET /api/v1/events/:event_id/subjects
      def index
        render json: @event.event_subjects.includes(:subject),
               each_serializer: EventSubjectSerializer
      end

      # POST /api/v1/events/:event_id/subjects
      # body: { subject_ids: [1, 2, 3] }
      def sync
        subject_ids = Array(params[:subject_ids]).map(&:to_i).uniq
        current_ids = @event.event_subjects.pluck(:subject_id)

        to_add    = subject_ids - current_ids
        to_remove = current_ids - subject_ids

        @event.event_subjects.where(subject_id: to_remove).destroy_all
        to_add.each { |sid| @event.event_subjects.create!(subject_id: sid) }

        render json: @event.event_subjects.includes(:subject),
               each_serializer: EventSubjectSerializer
      end

      private

      def set_event
        @event = Event.find(params[:id])
      end
    end
  end
end
