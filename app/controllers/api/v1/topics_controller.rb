module Api
  module V1
    class TopicsController < ApplicationController
      before_action :set_topic, only: [:show, :update, :destroy]
      before_action(only: [:create, :update, :destroy]) { require_role!(:ceo, :diretor, :equipe_pedagogica) }

      def index
        @topics = if params[:subject_id]
          Topic.where(subject_id: params[:subject_id]).order(:position)
        else
          Topic.all.order(:position)
        end
        render json: @topics, each_serializer: TopicSerializer
      end

      def show
        render json: @topic, serializer: TopicSerializer
      end

      def create
        @topic = Topic.new(topic_params)
        if @topic.save
          render json: @topic, serializer: TopicSerializer, status: :created
        else
          render json: { errors: @topic.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @topic.update(topic_params)
          render json: @topic, serializer: TopicSerializer
        else
          render json: { errors: @topic.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @topic.destroy
        head :no_content
      end

      private

      def set_topic
        @topic = Topic.find(params[:id])
      end

      def topic_params
        params.permit(:subject_id, :title, :position)
      end
    end
  end
end
