module Manage
  class PortalMessagesController < BaseController
    def index
      @creators = User.creator.includes(:account).order(:first_name)
      @threads = @creators.map do |creator|
        unread = PortalMessage.where(thread_owner: creator)
                              .where.not(sender_id: User.where(role: :admin).select(:id))
                              .unread.count
        last_msg = PortalMessage.where(thread_owner: creator).order(created_at: :desc).first
        { creator: creator, unread: unread, last_message: last_msg }
      end.select { |t| t[:last_message].present? }
       .sort_by { |t| [-t[:unread], -t[:last_message].created_at.to_i] }
    end

    def show
      @creator = User.find(params[:id])
      @messages = PortalMessage.where(thread_owner: @creator)
                               .general
                               .includes(:sender)
                               .order(created_at: :asc)
      # Mark all as read
      @messages.where.not(sender: current_user).unread.each(&:mark_read!)
    end

    def create
      @message = PortalMessage.new(
        sender: current_user,
        thread_owner_id: params[:portal_message][:thread_owner_id],
        submission_id: params[:portal_message][:submission_id],
        body: params[:portal_message][:body]
      )
      if @message.save
        PortalMailer.new_message(@message).deliver_later
        redirect_back fallback_location: manage_portal_messages_path, notice: 'Message sent.'
      else
        redirect_back fallback_location: manage_portal_messages_path, alert: 'Could not send message.'
      end
    end
  end
end
