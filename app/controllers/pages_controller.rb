class PagesController < ApplicationController
  def show
    @page = LandingPage.find_by!(slug: params[:slug], published: true)
    render layout: false
  end
end
