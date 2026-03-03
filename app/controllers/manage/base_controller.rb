module Manage
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    layout 'manage'

    helper_method :unread_admin_message_count

    private

    def require_admin!
      unless current_user.admin?
        redirect_to root_path, alert: 'Access denied.'
      end
    end

    def unread_admin_message_count
      @unread_admin_message_count ||= PortalMessage.where.not(sender_id: User.where(role: :admin).select(:id))
                                                    .unread
                                                    .count
    end
  end
end
