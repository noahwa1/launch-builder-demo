module Portal
  class ScheduledPostsController < BaseController
    before_action :set_campaign
    before_action :require_social_tools_enabled
    before_action :set_post

    def show
      @submission = @campaign.submission
      @author = @campaign.author
    end

    def update
      if @post.update(post_params)
        redirect_to portal_campaign_scheduled_post_path(@campaign, @post), notice: 'Post updated.'
      else
        @submission = @campaign.submission
        @author = @campaign.author
        render :show
      end
    end

    def destroy
      @post.destroy
      redirect_to portal_campaign_social_calendar_index_path(@campaign), notice: 'Post removed from calendar.'
    end

    private

    def require_social_tools_enabled
      require_feature!('social_tools')
    end

    def set_campaign
      @campaign = current_author.campaigns.find(params[:campaign_id])
    end

    def set_post
      @post = @campaign.scheduled_posts.find(params[:id])
    end

    def post_params
      params.require(:scheduled_post).permit(:platform, :category, :body, :scheduled_at, :status, :image)
    end
  end
end
