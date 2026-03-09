module Portal
  class NotificationsController < BaseController
    def index
      @notifications = current_user.notifications.recent.limit(50)
      @unread_count = current_user.notifications.unread.count
    end

    def mark_read
      notification = current_user.notifications.find(params[:id])
      notification.mark_read!
      if notification.url.present?
        redirect_to notification.url
      else
        redirect_to portal_notifications_path
      end
    end

    def mark_all_read
      current_user.notifications.unread.update_all(read_at: Time.current)
      redirect_to portal_notifications_path, notice: 'All notifications marked as read.'
    end

    def recent
      @notifications = current_user.notifications.recent.limit(10)
      @unread_count = current_user.notifications.unread.count
      render layout: false
    end
  end
end
