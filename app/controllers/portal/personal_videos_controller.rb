module Portal
  class PersonalVideosController < BaseController
    before_action :set_campaign
    before_action :require_personal_videos_enabled

    def queue_data
      submissions = @campaign.landing_page&.page_submissions&.recent || []

      queue = submissions.map do |ps|
        data = ps.data || {}
        pv = ps.personal_video

        {
          id: ps.id,
          name: data['name'] || data['first_name'] || 'Unknown',
          city: data['city'],
          state: data['state'],
          email: ps.email,
          status: pv&.status || 'pending',
          personal_video_id: pv&.id,
          created_at: ps.created_at
        }
      end

      total = queue.size
      done = queue.count { |q| q[:status] == 'sent' || q[:status] == 'recorded' }

      render json: { queue: queue, total: total, done: done }
    end

    def create
      submission = @campaign.landing_page.page_submissions.find(params[:page_submission_id])

      # Destroy existing for retakes
      existing = submission.personal_video
      existing&.destroy

      personal_video = @campaign.personal_videos.new(
        page_submission: submission,
        file: params[:file],
        status: :recorded
      )

      if personal_video.save
        next_sub = find_next_pending(submission.id)
        render json: {
          success: true,
          personal_video_id: personal_video.id,
          next_submission_id: next_sub&.id
        }
      else
        render json: { success: false, errors: personal_video.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def require_personal_videos_enabled
      require_feature!('personal_videos')
    end

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def find_next_pending(current_id)
      submission_ids = @campaign.landing_page.page_submissions.recent.pluck(:id)
      recorded_ids = @campaign.personal_videos.pluck(:page_submission_id)

      remaining = submission_ids - recorded_ids - [current_id]
      remaining.first ? PageSubmission.find(remaining.first) : nil
    end
  end
end
