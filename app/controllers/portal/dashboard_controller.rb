module Portal
  class DashboardController < BaseController
    def index
      if current_campaign
        redirect_to portal_campaign_path(current_campaign)
        return
      end

      @books_count = current_author.books.count
      @submissions = current_author.submissions.recent.limit(5)
      @submissions_by_status = current_author.submissions.group(:status).count
      @recent_payments = current_author.royalty_payments.recent.limit(3)
      @unread_messages = PortalMessage.where(thread_owner: current_user)
                                       .where.not(sender: current_user)
                                       .unread.count
    end
  end
end
