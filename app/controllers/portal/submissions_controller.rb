module Portal
  class SubmissionsController < BaseController
    before_action :set_submission, only: [:show, :edit, :update, :submit_for_review]

    def index
      @submissions = current_author.submissions.recent.page(params[:page]).per(10)
    end

    def show
    end

    def new
      @submission = current_author.submissions.build
    end

    def create
      @submission = current_author.submissions.build(submission_params)
      @submission.submitted_by = current_user.id

      if @submission.save
        redirect_to portal_submission_path(@submission), notice: 'Submission created as draft.'
      else
        render :new
      end
    end

    def edit
      redirect_to portal_submission_path(@submission), alert: 'Cannot edit submitted titles.' unless @submission.draft?
    end

    def update
      if @submission.draft? && @submission.update(submission_params)
        redirect_to portal_submission_path(@submission), notice: 'Submission updated.'
      else
        render :edit
      end
    end

    def submit_for_review
      if @submission.draft?
        @submission.submit!
        PortalMailer.submission_received(@submission).deliver_later
        redirect_to portal_submission_path(@submission), notice: 'Submitted for review!'
      else
        redirect_to portal_submission_path(@submission), alert: 'Already submitted.'
      end
    end

    private

    def set_submission
      @submission = current_author.submissions.find(params[:id])
    end

    def submission_params
      params.require(:submission).permit(:title, :isbn, :description, :cover, :release_date, :genre)
    end
  end
end
