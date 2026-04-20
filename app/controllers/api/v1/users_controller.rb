module Api
  module V1
    class UsersController < ApplicationController
      before_action -> { require_role!(:ceo, :diretor, :equipe_pedagogica, :assistente_comercial) }
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        q = User.ransack(params[:q])
        q.sorts = "name asc" if q.sorts.empty?
        @users = q.result(distinct: true)
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
        if @user.role == "professor"
          if Subject.exists?(professor_id: @user.id)
            return render json: { error: "Não é possível excluir este professor pois ele está vinculado a disciplinas." }, status: :unprocessable_entity
          end
        end

        if @user.role == "aluno"
          student_ids = Student.where(user_id: @user.id).pluck(:id)
          if Enrollment.where(student_id: student_ids).exists?
            return render json: { error: "Não é possível excluir este usuário pois ele possui matrículas vinculadas." }, status: :unprocessable_entity
          end
        end

        @user.update!(active: false)
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(:name, :email, :cpf, :password, :role, :commission_percent, :active, :user_type_id)
      end

      def update_params
        p = params.permit(:name, :email, :cpf, :password, :role, :commission_percent, :active, :user_type_id)
        p.delete(:password) if p[:password].blank?
        p
      end
    end
  end
end
