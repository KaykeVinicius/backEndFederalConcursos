module Api
  module V1
    class PasswordSetupsController < ApplicationController
      skip_before_action :authenticate_user!

      # GET /api/v1/auth/setup_password/validate?token=XXX
      # Valida o token e retorna nome do aluno (para exibir na página)
      def validate
        user = User.find_by(setup_password_token: params[:token])

        if user.nil? || !user.setup_token_valid?(params[:token])
          return render json: { error: "Link inválido ou expirado." }, status: :unprocessable_entity
        end

        render json: { name: user.name, email: user.email }
      end

      # POST /api/v1/auth/setup_password
      # Corpo: { token, password, password_confirmation }
      def setup
        user = User.find_by(setup_password_token: params[:token])

        if user.nil? || !user.setup_token_valid?(params[:token])
          return render json: { error: "Link inválido ou expirado." }, status: :unprocessable_entity
        end

        unless params[:password] == params[:password_confirmation]
          return render json: { error: "As senhas não coincidem." }, status: :unprocessable_entity
        end

        unless strong_password?(params[:password])
          return render json: {
            error: "A senha não atende aos requisitos mínimos de segurança."
          }, status: :unprocessable_entity
        end

        user.password              = params[:password]
        user.password_confirmation = params[:password_confirmation]
        user.active                = true
        user.setup_password_token            = nil
        user.setup_password_token_expires_at = nil

        if user.save
          render json: { message: "Senha criada com sucesso. Você já pode fazer login." }
        else
          render json: { error: user.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      private

      def strong_password?(password)
        return false if password.nil? || password.length < 8
        return false unless password.match?(/[A-Z]/)      # maiúscula
        return false unless password.match?(/[a-z]/)      # minúscula
        return false unless password.match?(/[0-9]/)      # número
        return false unless password.match?(/[^A-Za-z0-9]/) # especial
        true
      end
    end
  end
end
