module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: [:login]

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email].to_s.downcase)

        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id, role: user.role)
          render json: {
            token: token,
            user: UserSerializer.new(user).as_json
          }, status: :ok
        else
          render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
        end
      end

      # GET /api/v1/auth/me
      def me
        render json: UserSerializer.new(current_user).as_json
      end
    end
  end
end