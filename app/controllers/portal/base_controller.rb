module Portal
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_creator!
    layout 'portal'

    helper_method :current_author, :unread_message_count

    private

    def current_author
      @current_author ||= current_user.author
    end

    def require_creator!
      unless current_user.creator? && current_author.present?
        redirect_to root_path, alert: 'Access denied.'
      end
    end

    def unread_message_count
      @unread_message_count ||= PortalMessage.where(thread_owner: current_user)
                                              .where.not(sender: current_user)
                                              .unread
                                              .count
    end
  end
end
