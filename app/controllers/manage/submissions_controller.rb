module Manage
  class SubmissionsController < BaseController
    before_action :set_submission, only: [:show, :approve, :reject, :mark_in_review, :reply]

    def index
      @submissions = Submission.includes(:author, :submitter).recent
      @submissions = @submissions.where(status: params[:status]) if params[:status].present?
      @submissions = @submissions.page(params[:page]).per(15)
      @pending_count = Submission.pending_review.count
    end

    def show
      @messages = @submission.portal_messages.includes(:sender).order(created_at: :asc)
    end

    def approve
      @submission.approve!(current_user)
      PortalMailer.submission_approved(@submission).deliver_later
      redirect_to manage_submission_path(@submission), notice: 'Submission approved.'
    end

    def reject
      @submission.reject!(current_user, params[:admin_notes])
      PortalMailer.submission_rejected(@submission).deliver_later
      redirect_to manage_submission_path(@submission), notice: 'Submission rejected.'
    end

    def mark_in_review
      @submission.mark_in_review!(current_user)
      redirect_to manage_submission_path(@submission), notice: 'Marked as in review.'
    end

    def reply
      message = PortalMessage.new(
        sender: current_user,
        thread_owner: @submission.submitter,
        submission: @submission,
        body: params[:body]
      )
      if message.save
        PortalMailer.new_message(message).deliver_later
        redirect_to manage_submission_path(@submission), notice: 'Reply sent.'
      else
        redirect_to manage_submission_path(@submission), alert: 'Could not send reply.'
      end
    end

    private

    def set_submission
      @submission = Submission.find(params[:id])
    end
  end
end
