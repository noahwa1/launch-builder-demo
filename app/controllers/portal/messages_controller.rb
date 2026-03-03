module Portal
  class MessagesController < BaseController
    def index
      @messages = PortalMessage.where(thread_owner: current_user)
                               .general
                               .recent
                               .page(params[:page]).per(20)
      mark_as_read(@messages)
    end

    def submission_thread
      @submission = current_author.submissions.find(params[:submission_id])
      @messages = PortalMessage.where(thread_owner: current_user, submission: @submission)
                               .recent
                               .page(params[:page]).per(20)
      mark_as_read(@messages)
    end

    def create
      @message = PortalMessage.new(message_params)
      @message.sender = current_user
      @message.thread_owner = current_user

      if @message.save
        PortalMailer.new_message(@message).deliver_later
        redirect_back fallback_location: portal_messages_path, notice: 'Message sent.'
      else
        redirect_back fallback_location: portal_messages_path, alert: 'Could not send message.'
      end
    end

    private

    def mark_as_read(messages)
      messages.where.not(sender: current_user).unread.each(&:mark_read!)
    end

    def message_params
      params.require(:portal_message).permit(:body, :submission_id)
    end
  end
end
