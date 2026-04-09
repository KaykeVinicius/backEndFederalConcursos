module Api
  module V1
    class CitiesController < ApplicationController
      # GET /api/v1/cities?q=porto&state=RO
      def index
        cities = City.ordered
        cities = cities.where("state ILIKE ?", params[:state]) if params[:state].present?
        cities = cities.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
        cities = cities.limit(50)
        render json: cities, each_serializer: CitySerializer
      end
    end
  end
end
