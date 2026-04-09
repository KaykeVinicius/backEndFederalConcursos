module Api
  module V1
    class NotificationsController < ApplicationController
      # GET /api/v1/notifications
      def index
        notifications = current_user.notifications.recent
        render json: notifications, each_serializer: NotificationSerializer
      end

      # PATCH /api/v1/notifications/mark_all_read
      def mark_all_read
        current_user.notifications.unread.update_all(read_at: Time.current)
        head :no_content
      end

      # PATCH /api/v1/notifications/:id/mark_read
      def mark_read
        notif = current_user.notifications.find(params[:id])
        notif.update!(read_at: Time.current)
        render json: notif, serializer: NotificationSerializer
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Não encontrado" }, status: :not_found
      end
    end
  end
end
