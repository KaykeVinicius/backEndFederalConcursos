module Api
  module V1
    class CareersController < ApplicationController
      before_action :set_career, only: [:show, :update, :destroy]
      before_action(only: [:create, :update, :destroy]) { require_role!(:ceo, :diretor, :equipe_pedagogica) }

      def index
        @careers = Career.order(created_at: :desc)
        render json: @careers, each_serializer: CareerSerializer
      end

      def show
        render json: @career, serializer: CareerSerializer
      end

      def create
        @career = Career.new(career_params)
        if @career.save
          render json: @career, serializer: CareerSerializer, status: :created
        else
          render json: { errors: @career.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @career.update(career_params)
          render json: @career, serializer: CareerSerializer
        else
          render json: { errors: @career.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if Course.exists?(career_id: @career.id)
          return render json: { error: "Não é possível excluir esta carreira pois ela está vinculada a cursos." }, status: :unprocessable_entity
        end
        @career.destroy
        head :no_content
      end

      private

      def set_career
        @career = Career.find(params[:id])
      end

      def career_params
        params.permit(:name, :description)
      end
    end
  end
end
