module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: [:login]

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email].to_s.downcase)
        ua   = request.user_agent.to_s

        if user&.authenticate(params[:password])
          record_access_log(user, ua, success: true)
          session_token = user.rotate_session_token!
          token = JsonWebToken.encode(user_id: user.id, role: user.role, session_token: session_token)
          render json: {
            token: token,
            user: UserSerializer.new(user).as_json
          }, status: :ok
        else
          record_access_log(user, ua, success: false) if user
          render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
        end
      end

      # GET /api/v1/auth/me
      def me
        render json: UserSerializer.new(current_user).as_json
      end

      # DELETE /api/v1/auth/logout
      def logout
        current_user.update_column(:session_token, nil)
        head :no_content
      end

      private

      def record_access_log(user, ua, success:)
        AccessLog.create!(
          user:        user,
          ip_address:  request.remote_ip,
          user_agent:  ua,
          device:      AccessLog.parse_device(ua),
          browser:     AccessLog.parse_browser(ua),
          action:      "login",
          success:     success
        )
      rescue => e
        Rails.logger.error "[AuthController] Erro ao gravar log: #{e.message}"
      end
    end
  end
end