module DeadlineChecker
  ALERT_DAYS = [3, 1].freeze

  DEADLINES = [
    { field: :content_deadline, label: 'Content Deadline' },
    { field: :review_deadline,  label: 'Review Deadline' },
    { field: :launch_date,      label: 'Launch Date' }
  ].freeze

  module_function

  def check_all
    Campaign.active.find_each do |campaign|
      DEADLINES.each do |dl|
        date = campaign.send(dl[:field])
        next unless date

        days_left = (date - Date.today).to_i
        next unless ALERT_DAYS.include?(days_left)

        # Avoid duplicate notifications (check if we already sent one today for this deadline)
        already_sent = Notification.where(
          campaign: campaign,
          notification_type: 'deadline_approaching',
          created_at: Date.today.all_day
        ).where("title LIKE ?", "%#{dl[:label]}%").exists?

        next if already_sent

        NotificationService.deadline_approaching(campaign, dl[:label], days_left)
        PortalMailer.deadline_approaching(campaign, dl[:label], days_left).deliver_later
      end
    end
  end
end
