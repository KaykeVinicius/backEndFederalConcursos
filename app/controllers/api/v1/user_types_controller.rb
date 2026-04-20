module Api
  module V1
    class UserTypesController < ApplicationController
      before_action { require_role!(:ceo, :diretor, :equipe_pedagogica, :assistente_comercial, :professor) }

      # GET /api/v1/user_types
      def index
        render json: UserType.active.ordered, each_serializer: UserTypeSerializer
      end
    end
  end
end
