module Api
  module V1
    class AnnouncementsController < ApplicationController
      before_action :set_announcement, only: [:show, :update, :destroy]
      before_action :require_admin_or_diretor!, only: [:create, :update, :destroy]

      # GET /api/v1/announcements
      # Filtros opcionais: apenas ativos e para o público do usuário atual
      def index
        scope = Announcement.includes(:author)

        # Alunos e professores veem apenas avisos ativos para sua audiência
        if current_user.role.in?(%w[aluno professor])
          scope = scope.active.for_audience(current_user.role)
        end

        q = scope.ransack(params[:q])
        q.sorts = "pinned desc, created_at desc" if q.sorts.empty?
        @announcements = q.result(distinct: true)

        render json: @announcements, each_serializer: AnnouncementSerializer
      end

      def show
        render json: @announcement, serializer: AnnouncementSerializer
      end

      def create
        @announcement = Announcement.new(announcement_params.merge(author: current_user))
        if @announcement.save
          render json: @announcement, serializer: AnnouncementSerializer, status: :created
        else
          render json: { errors: @announcement.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @announcement.update(announcement_params)
          render json: @announcement, serializer: AnnouncementSerializer
        else
          render json: { errors: @announcement.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @announcement.update!(active: false)
        head :no_content
      end

      private

      def set_announcement
        @announcement = Announcement.find(params[:id])
      end

      def announcement_params
        params.permit(:title, :body, :category, :audience, :pinned, :active, :expires_at)
      end

      def require_admin_or_diretor!
        require_role!(:ceo, :diretor, :equipe_pedagogica, :assistente_comercial)
      end
    end
  end
end
