module Manage
  class CampaignsController < BaseController
    before_action :set_campaign, only: [:show, :edit, :update, :toggle_checklist_item, :update_settings]

    def index
      @campaigns = Campaign.includes(:author, :checklist_items, :campaign_assets)
                           .order(created_at: :desc)
                           .page(params[:page]).per(15)
    end

    def show
      @items_by_category = @campaign.items_by_category
      @pending_assets = @campaign.campaign_assets.pending.order(created_at: :desc)
      @all_assets = @campaign.campaign_assets.order(created_at: :desc)
      @landing_page = @campaign.landing_page
    end

    def new
      @authors = Author.active.order(:full_name)
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
          submission:       @submission,
          author:           @author,
          title:            params[:title],
          example_category: params[:example_category].presence
        )
      end

      redirect_to manage_campaign_path(@campaign), notice: 'Campaign created — author, submission, and checklist are ready.'
    rescue ActiveRecord::RecordInvalid => e
      @authors = Author.active.order(:full_name)
      flash.now[:alert] = e.record.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end

    def edit
      @authors = Author.active.order(:full_name)
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
      redirect_to manage_campaign_path(@campaign), notice: "\"#{item.title}\" updated."
    end

    def update_settings
      @campaign.update!(params.require(:campaign).permit(:example_category))
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
      params.permit(:title, :example_category)
    end
  end
end
