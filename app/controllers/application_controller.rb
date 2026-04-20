class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    if token.blank?
      render json: { error: "Token não fornecido" }, status: :unauthorized and return
    end

    begin
      payload = JsonWebToken.decode(token)
      @current_user = User.find(payload[:user_id])

      unless @current_user.active?
        render json: { error: "Usuário inativo" }, status: :unauthorized and return
      end

      # Bloqueio de sessão simultânea: verifica se o session_token do JWT ainda é válido
      # Usuários antigos (sem session_token no JWT) ainda são aceitos durante a transição
      if payload[:session_token].present? &&
         @current_user.session_token != payload[:session_token]
        render json: { error: "Sessão encerrada. Faça login novamente." }, status: :unauthorized
      end
    rescue JWT::ExpiredSignature
      render json: { error: "Token expirado" }, status: :unauthorized
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: "Token inválido" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def require_role!(*roles)
    unless roles.map(&:to_s).include?(@current_user.role)
      render json: { error: "Acesso não autorizado" }, status: :forbidden
    end
  end

  def require_professor!
    require_role!(:professor)
  end

  def require_aluno!
    require_role!(:aluno)
  end

  # Retorna todos os IDs de students vinculados ao usuário atual
  # (um usuário pode ter mais de um student quando matriculado como ex-aluno)
  def current_student_ids
    @current_student_ids ||= Student.where(user_id: current_user.id).pluck(:id)
  end

  # Retorna o student principal (para operações de escrita)
  def current_student
    @current_student ||= Student.where(user_id: current_user.id).first
  end

  def require_admin!
    require_role!(:ceo, :diretor, :equipe_pedagogica, :admin)
  end
end