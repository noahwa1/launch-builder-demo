module Portal
  class DashboardController < BaseController
    def index
      if current_campaign
        redirect_to portal_campaign_path(current_campaign)
        return
      end

      @campaigns = current_author.campaigns.order(created_at: :desc)
      @books_count = current_author.books.count
      @submissions = current_author.submissions.recent.limit(5)
      @submissions_by_status = current_author.submissions.group(:status).count
      @recent_payments = current_author.royalty_payments.recent.limit(3)
      @unread_messages = PortalMessage.where(thread_owner: current_user)
                                       .where.not(sender: current_user)
                                       .unread.count

      # Pending actions across all campaigns
      @pending_actions = 0
      @action_details = []
      @upcoming_deadlines = []

      @campaigns.each do |c|
        # Unreviewed deliverables
        if c.deliverables_enabled?
          pending_del = c.admin_deliverables.where(status: [:pending_review, :revised]).count
          if pending_del > 0
            @pending_actions += pending_del
            @action_details << { campaign: c, text: "#{pending_del} deliverable#{'s' if pending_del > 1} to review", url: "/portal/campaigns/#{c.id}/deliverables" }
          end
        end

        # Unconfirmed sections (in setup phase)
        if c.setup?
          unconfirmed = Campaign::CONFIRMABLE_SECTIONS.count { |s| !c.section_confirmed?(s) }
          if unconfirmed > 0
            @pending_actions += unconfirmed
            @action_details << { campaign: c, text: "#{unconfirmed} section#{'s' if unconfirmed > 1} to confirm", url: "/portal/campaigns/#{c.id}" }
          end
        end

        # Incomplete required checklist items (if in content phase)
        if c.content? && c.asset_uploads_enabled?
          incomplete = c.checklist_items.where(category: 'content').required.incomplete.count
          if incomplete > 0
            @pending_actions += incomplete
            @action_details << { campaign: c, text: "#{incomplete} content item#{'s' if incomplete > 1} to complete", url: "/portal/campaigns/#{c.id}/campaign_assets" }
          end
        end

        # Upcoming deadlines
        [[c.content_deadline, 'Content Deadline'], [c.review_deadline, 'Review Deadline'], [c.launch_date, 'Launch Date']].each do |date, label|
          next unless date && date > Date.today && date <= 14.days.from_now.to_date
          @upcoming_deadlines << { campaign: c, label: label, date: date, days: (date - Date.today).to_i }
        end
      end

      @upcoming_deadlines.sort_by! { |d| d[:date] }
      @recent_activities = CampaignActivity.where(campaign: @campaigns).recent.includes(:user, :campaign).select { |a| a.portal_visible? }.first(10)
    end
  end
end
