module Api
  module V1
    class AccessLogsController < ApplicationController
      before_action { require_role!(:ceo, :diretor) }

      # GET /api/v1/access_logs
      # Suporta params[:q] (Ransack) e page/per_page
      def index
        q    = AccessLog.includes(:user).ransack(params[:q])
        q.sorts = "created_at desc" if q.sorts.empty?
        logs = q.result(distinct: true)

        # filtros legados mantidos por compatibilidade
        logs = logs.where(user_id: params[:user_id]) if params[:user_id].present?
        logs = logs.where(success: params[:success]) if params[:success].present?

        total = logs.count
        per   = (params[:per_page] || 50).to_i
        page  = (params[:page] || 1).to_i
        logs  = logs.offset((page - 1) * per).limit(per)

        render json: {
          total:    total,
          page:     page,
          per_page: per,
          logs:     logs.map { |l| serialize_log(l) }
        }
      end

      private

      def serialize_log(log)
        {
          id:          log.id,
          action:      log.action,
          success:     log.success,
          ip_address:  log.ip_address,
          device:      log.device,
          browser:     log.browser,
          user_agent:  log.user_agent,
          created_at:  log.created_at,
          user: {
            id:    log.user.id,
            name:  log.user.name,
            email: log.user.email,
            role:  log.user.role,
          }
        }
      end
    end
  end
end
