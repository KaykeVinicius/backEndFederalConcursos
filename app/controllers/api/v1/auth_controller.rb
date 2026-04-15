module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: [:login, :forgot_password]

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

      # POST /api/v1/auth/forgot_password
      def forgot_password
        cpf  = params[:cpf].to_s.gsub(/\D/, "")   # remove pontos e traço
        user = User.find_by(cpf: cpf)

        if user
          token     = user.generate_reset_token!
          frontend  = ENV.fetch("FRONTEND_URL", "http://localhost:3000")
          reset_url = "#{frontend}/reset-password?token=#{token}"
          UserMailer.reset_password_email(user, reset_url).deliver_now
        end

        # Sempre retorna sucesso — não revela se o CPF existe ou não
        render json: { message: "Se este CPF estiver cadastrado, o link de redefinição será enviado para o e-mail vinculado." }
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