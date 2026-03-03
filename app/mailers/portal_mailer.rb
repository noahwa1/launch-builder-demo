class PortalMailer < ApplicationMailer
  default from: 'portal@launch-publishing.com'

  def submission_received(submission)
    @submission = submission
    @author = submission.author
    mail(
      to: User.admin.pluck(:email),
      subject: "New submission: #{@submission.title} by #{@author.full_name}"
    )
  end

  def submission_approved(submission)
    @submission = submission
    @creator = submission.submitter
    mail(
      to: @creator.email,
      subject: "Your submission \"#{@submission.title}\" has been approved!"
    )
  end

  def submission_rejected(submission)
    @submission = submission
    @creator = submission.submitter
    mail(
      to: @creator.email,
      subject: "Update on your submission \"#{@submission.title}\""
    )
  end

  def new_message(message)
    @message = message
    @recipient = if message.sender.admin?
                   message.thread_owner
                 else
                   User.admin.first
                 end
    return unless @recipient

    mail(
      to: @recipient.email,
      subject: "New message from #{message.sender.full_name}"
    )
  end

  def payment_processed(payment)
    @payment = payment
    @author = payment.author
    @creator = @author.user
    return unless @creator

    mail(
      to: @creator.email,
      subject: "Royalty payment of $#{@payment.amount} has been processed"
    )
  end
end
