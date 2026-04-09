module Api
  module V1
    class UserTypesController < ApplicationController
      before_action :set_user_type, only: [:update, :destroy]
      before_action { require_role!(:ceo, :diretor) }

      # GET /api/v1/user_types
      def index
        render json: UserType.ordered, each_serializer: UserTypeSerializer
      end

      # POST /api/v1/user_types
      def create
        @user_type = UserType.new(user_type_params)
        if @user_type.save
          render json: @user_type, serializer: UserTypeSerializer, status: :created
        else
          render json: { errors: @user_type.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/user_types/:id
      def update
        if @user_type.update(user_type_params)
          render json: @user_type, serializer: UserTypeSerializer
        else
          render json: { errors: @user_type.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/user_types/:id
      def destroy
        if @user_type.users.exists?
          render json: { error: "Não é possível excluir: existem usuários deste tipo." }, status: :unprocessable_entity
        else
          @user_type.destroy
          head :no_content
        end
      end

      private

      def set_user_type
        @user_type = UserType.find(params[:id])
      end

      def user_type_params
        params.permit(:name, :slug, :description, :active, :position)
      end
    end
  end
end
