module Portal
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_creator!
    layout 'portal'

    helper_method :current_author, :unread_message_count, :unread_notification_count, :current_campaign

    private

    def current_author
      @current_author ||= current_user.author
    end

    def current_campaign
      @current_campaign ||= current_author&.campaigns&.order(created_at: :desc)&.first
    end

    def require_creator!
      unless current_user.creator? && current_author.present?
        sign_out current_user
      redirect_to new_user_session_path, alert: 'Access denied. Your account needs to be linked to an author profile.'
      end
    end

    def unread_message_count
      @unread_message_count ||= PortalMessage.where(thread_owner: current_user)
                                              .where.not(sender: current_user)
                                              .unread
                                              .count
    end

    def unread_notification_count
      @unread_notification_count ||= current_user.notifications.unread.count
    end
  end
end
