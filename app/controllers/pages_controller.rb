class PagesController < ApplicationController
  skip_forgery_protection only: :submit

  def show
    @page = LandingPage.find_by!(slug: params[:slug], published: true)
    render layout: false
  end

  def submit
    @page = LandingPage.find_by!(slug: params[:slug], published: true)

    # Collect all form fields as JSON data (include ref code if present)
    field_data = params.except(:controller, :action, :slug, :receipt, :authenticity_token, :form_type).permit!.to_h
    field_data['ref'] = params[:ref] if params[:ref].present?
    form_type = params[:form_type].presence || detect_form_type(field_data)

    submission = @page.page_submissions.new(
      form_type: form_type,
      data: field_data,
      email: field_data['email'] || field_data['Email'],
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    submission.receipt = params[:receipt] if params[:receipt].present?

    if submission.save
      if @page.respond_to?(:campaign) && @page.campaign
        CampaignActivityLogger.submission_received(@page.campaign, submission)
        NotificationService.submission_received(@page.campaign, submission)
      end
      if @page.notify_on_submission?
        PortalMailer.new_page_submission(submission).deliver_later
      end
      render json: { success: true, message: 'Thank you! Your submission has been received.' }
    else
      render json: { success: false, message: 'Something went wrong. Please try again.' }, status: :unprocessable_entity
    end
  end

  private

  def detect_form_type(data)
    keys = data.keys.map(&:downcase)
    if keys.any? { |k| k.include?('address') || k.include?('city') || k.include?('state') || k.include?('postal') }
      'address_capture'
    elsif keys.any? { |k| k.include?('retailer') || k.include?('confirmation') || k.include?('receipt') }
      'order_confirmation'
    else
      'contact'
    end
  end
end
