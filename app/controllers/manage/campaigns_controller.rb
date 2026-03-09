module Manage
  class CampaignsController < BaseController
    before_action :set_campaign, only: [:show, :edit, :update, :toggle_checklist_item, :update_settings, :set_phase, :advance_phase, :duplicate]

    def index
      if params[:view] == 'deliverables'
        @view_mode = 'deliverables'
        @all_deliverables = AdminDeliverable.includes(:campaign).recent
        @pending_deliverables = @all_deliverables.where(status: [:pending_review, :revised])
        @campaigns = Campaign.none.page(1) # satisfy paginate
      else
        @view_mode = 'list'
        @campaigns = Campaign.includes(:author, :checklist_items, :campaign_assets)
                             .order(created_at: :desc)
                             .page(params[:page]).per(15)
      end
    end

    def bulk_advance
      campaign_ids = params[:campaign_ids] || []
      advanced = []
      Campaign.where(id: campaign_ids).each do |c|
        if c.can_advance?
          old_phase = c.phase
          c.advance_phase!
          c.skip_empty_phases!
          CampaignActivityLogger.phase_advanced(c, old_phase, c.phase, current_user)
          NotificationService.phase_advanced(c, c.phase)
          advanced << c.title
        end
      end
      if advanced.any?
        redirect_to manage_campaigns_path, notice: "Advanced #{advanced.size} campaign#{'s' if advanced.size > 1}: #{advanced.join(', ')}"
      else
        redirect_to manage_campaigns_path, alert: 'No campaigns could be advanced.'
      end
    end

    def bulk_message
      campaign_ids = params[:campaign_ids] || []
      body = params[:message_body].to_s.strip
      if body.blank?
        redirect_to manage_campaigns_path, alert: 'Message body cannot be blank.'
        return
      end

      sent = 0
      Campaign.where(id: campaign_ids).includes(:author).each do |c|
        creator_user = c.author&.user
        next unless creator_user

        msg = PortalMessage.create!(
          sender: current_user,
          thread_owner: creator_user,
          body: body
        )
        PortalMailer.new_message(msg).deliver_later
        NotificationService.message_received(c, msg, creator_user)
        sent += 1
      end
      redirect_to manage_campaigns_path, notice: "Message sent to #{sent} creator#{'s' if sent > 1}."
    end

    def show
      @items_by_category = @campaign.items_by_category
      @pending_assets = @campaign.campaign_assets.pending.order(created_at: :desc)
      @all_assets = @campaign.campaign_assets.order(created_at: :desc)
      @landing_page = @campaign.landing_page
      @confirmations = @campaign.creator_confirmations.index_by(&:section)
      @activities = @campaign.activities.recent.includes(:user).limit(50)
    end

    def new
      @authors = Author.active.order(:full_name)
      @books = Book.order(:title)
    end

    def create
      ActiveRecord::Base.transaction do
        # 1. Find or create Author
        if params[:existing_author_id].present?
          @author = Author.find(params[:existing_author_id])
        else
          @author = Author.create!(author_params)
        end

        # 2. Create User (role: creator) if author has no account
        if @author.user.blank? && params[:creator_email].present?
          User.create!(
            email:      params[:creator_email],
            password:   params[:creator_password],
            role:       :creator,
            account:    @author,
            first_name: @author.first_name,
            last_name:  @author.last_name
          )
        end

        # 3. Create Submission (status: approved, skip approval email)
        @submission = Submission.create!(
          author:       @author,
          submitter:    current_user,
          title:        params[:title],
          isbn:         params[:isbn],
          description:  params[:book_description],
          genre:        params[:genre],
          release_date: params[:release_date],
          cover:        params[:cover],
          status:       :approved,
          reviewed_by:  current_user.id,
          reviewed_at:  Time.current,
          submitted_at: Time.current
        )

        # 4. Create Campaign directly (triggers checklist + landing page via after_create)
        @campaign = Campaign.create!(
          submission:            @submission,
          author:                @author,
          title:                 params[:title],
          example_category:      params[:example_category].presence,
          book_id:               params[:book_id].presence,
          brief:                 params[:brief],
          launch_date:           params[:launch_date],
          content_deadline:      params[:content_deadline],
          review_deadline:       params[:review_deadline],
          signed_editions_url:   params[:signed_editions_url],
          bookplate_address:     params[:bookplate_address],
          management_emails:     params[:management_emails],
          bookplate_design:      params[:bookplate_design],
          ad_access_notes:       params[:ad_access_notes],
          campaign_type:         params[:campaign_type].presence || 'full',
          landing_page_enabled:  params[:landing_page_enabled] == '1',
          asset_uploads_enabled: params[:asset_uploads_enabled] == '1',
          deliverables_enabled:  params[:deliverables_enabled] == '1',
          live_events_enabled:   params[:live_events_enabled] == '1',
          personal_videos_enabled: params[:personal_videos_enabled] == '1',
          social_tools_enabled:  params[:social_tools_enabled] == '1',
          fan_crm_enabled:       params[:fan_crm_enabled] == '1',
          royalties_enabled:     params[:royalties_enabled] == '1'
        )
      end

      CampaignActivityLogger.campaign_created(@campaign, current_user)
      redirect_to manage_campaign_path(@campaign), notice: 'Campaign created — author, submission, and checklist are ready.'
    rescue ActiveRecord::RecordInvalid => e
      @authors = Author.active.order(:full_name)
      @books = Book.order(:title)
      flash.now[:alert] = e.record.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end

    def edit
      @authors = Author.active.order(:full_name)
      @books = Book.order(:title)
      @submission = @campaign.submission
    end

    def update
      ActiveRecord::Base.transaction do
        # Update author details
        @campaign.author.update!(author_params) if author_params.values.any?(&:present?)

        # Update submission (book details)
        @campaign.submission.update!(submission_params)

        # Update campaign
        @campaign.update!(campaign_params)
      end

      redirect_to manage_campaign_path(@campaign), notice: 'Campaign updated.'
    rescue ActiveRecord::RecordInvalid => e
      @authors = Author.active.order(:full_name)
      @books = Book.order(:title)
      @submission = @campaign.submission
      flash.now[:alert] = e.record.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end

    def toggle_checklist_item
      item = @campaign.checklist_items.find(params[:checklist_item_id])
      if item.complete?
        item.reset!
      else
        item.mark_complete!
      end
      CampaignActivityLogger.checklist_toggled(@campaign, item, current_user)
      redirect_to manage_campaign_path(@campaign), notice: "\"#{item.title}\" updated."
    end

    def set_phase
      @campaign.update!(phase: params[:phase])
      CampaignActivityLogger.phase_set(@campaign, @campaign.phase, current_user)
      redirect_to manage_campaign_path(@campaign), notice: "Phase updated to #{@campaign.phase.titleize}."
    end

    def advance_phase
      if @campaign.can_advance?
        old_phase = @campaign.phase
        @campaign.advance_phase!
        @campaign.skip_empty_phases!
        CampaignActivityLogger.phase_advanced(@campaign, old_phase, @campaign.phase, current_user)
        NotificationService.phase_advanced(@campaign, @campaign.phase)
        redirect_to manage_campaign_path(@campaign), notice: "Advanced to #{@campaign.phase.titleize} phase."
      else
        redirect_to manage_campaign_path(@campaign), alert: "Cannot advance — #{@campaign.phase_blockers.to_sentence}."
      end
    end

    def duplicate
      # Determine author for the new campaign
      if params[:author_id].present?
        author = Author.find(params[:author_id])
      else
        author = @campaign.author
      end

      # Offset dates to the future
      date_offset = @campaign.launch_date.present? ? (Date.today - @campaign.launch_date).to_i.days : 0.days

      # Create a new submission for the duplicated campaign (unique constraint on submission_id)
      new_submission = Submission.create!(
        author: author,
        submitter: current_user,
        title: "#{@campaign.title} (Copy)",
        isbn: @campaign.submission.isbn,
        description: @campaign.submission.description,
        genre: @campaign.submission.genre,
        release_date: @campaign.submission.release_date,
        status: :approved,
        reviewed_by: current_user.id,
        reviewed_at: Time.current,
        submitted_at: Time.current
      )

      new_campaign = Campaign.create!(
        submission: new_submission,
        author: author,
        title: "#{@campaign.title} (Copy)",
        example_category: @campaign.example_category,
        brief: @campaign.brief,
        launch_date: @campaign.launch_date.present? ? @campaign.launch_date + date_offset : nil,
        content_deadline: @campaign.content_deadline.present? ? @campaign.content_deadline + date_offset : nil,
        review_deadline: @campaign.review_deadline.present? ? @campaign.review_deadline + date_offset : nil,
        signed_editions_url: @campaign.signed_editions_url,
        bookplate_address: @campaign.bookplate_address,
        management_emails: @campaign.management_emails,
        ad_access_notes: @campaign.ad_access_notes,
        campaign_type: @campaign.campaign_type,
        landing_page_enabled: @campaign.landing_page_enabled?,
        asset_uploads_enabled: @campaign.asset_uploads_enabled?,
        deliverables_enabled: @campaign.deliverables_enabled?,
        live_events_enabled: @campaign.live_events_enabled?,
        personal_videos_enabled: @campaign.personal_videos_enabled?,
        social_tools_enabled: @campaign.social_tools_enabled?,
        fan_crm_enabled: @campaign.fan_crm_enabled?,
        royalties_enabled: @campaign.royalties_enabled?,
        phase: :setup
      )

      CampaignActivityLogger.campaign_created(new_campaign, current_user)
      redirect_to manage_campaign_path(new_campaign), notice: "Campaign duplicated from \"#{@campaign.title}\"."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to manage_campaign_path(@campaign), alert: "Could not duplicate: #{e.record.errors.full_messages.join(', ')}"
    end

    def update_settings
      @campaign.update!(params.require(:campaign).permit(
        :example_category, :personal_videos_enabled,
        :brief, :launch_date, :content_deadline, :review_deadline,
        :signed_editions_url, :bookplate_address, :management_emails,
        :ad_access_notes, :campaign_type, :landing_page_enabled,
        :asset_uploads_enabled, :deliverables_enabled, :live_events_enabled,
        :social_tools_enabled, :fan_crm_enabled, :royalties_enabled
      ))
      redirect_to manage_campaign_path(@campaign), notice: 'Campaign settings updated.'
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    def author_params
      params.permit(:first_name, :last_name, :description, :image)
    end

    def submission_params
      params.permit(:title, :isbn, :book_description, :genre, :release_date, :cover).tap do |p|
        p[:description] = p.delete(:book_description) if p.key?(:book_description)
        p.reject! { |_, v| v.nil? }
      end
    end

    def campaign_params
      params.permit(
        :title, :example_category, :book_id, :brief,
        :launch_date, :content_deadline, :review_deadline,
        :signed_editions_url, :bookplate_address, :management_emails,
        :bookplate_design, :ad_access_notes, :personal_videos_enabled,
        :campaign_type, :landing_page_enabled, :asset_uploads_enabled,
        :deliverables_enabled, :live_events_enabled, :social_tools_enabled,
        :fan_crm_enabled, :royalties_enabled
      )
    end
  end
end
