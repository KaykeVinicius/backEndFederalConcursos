module Api
  module V1
    class UsersController < ApplicationController
      before_action -> { require_role!(:ceo, :diretor, :equipe_pedagogica, :assistente_comercial) }
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        @users = User.order(:name)
        render json: @users, each_serializer: UserSerializer
      end

      def show
        render json: @user, serializer: UserSerializer
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user, serializer: UserSerializer, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(update_params)
          render json: @user, serializer: UserSerializer
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @user.update!(active: false)
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(:name, :email, :cpf, :password, :role, :commission_percent, :active)
      end

      def update_params
        p = params.permit(:name, :email, :cpf, :password, :role, :commission_percent, :active)
        p.delete(:password) if p[:password].blank?
        p
      end
    end
  end
end
