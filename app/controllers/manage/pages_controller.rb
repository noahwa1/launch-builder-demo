module Manage
  class PagesController < BaseController
    before_action :set_page, only: [:show, :edit, :update, :destroy, :builder, :toggle_publish, :generate]

    def index
      @pages = LandingPage.where(campaign_id: nil)
                          .order(created_at: :desc)
                          .page(params[:page]).per(20)
    end

    def new
      @authors = Author.active.order(:full_name)
      @books = Book.includes(:author).order(:title)
    end

    def create
      @page = LandingPage.new(
        title: params[:title],
        slug: params[:slug].presence,
        author_id: params[:author_id].presence
      )
      if @page.save
        if params[:generate_page] == '1'
          author = @page.author
          book = params[:book_id].present? ? Book.find(params[:book_id]) : nil
          result = LandingPageGenerator.new(nil,
            author: author,
            book: book,
            company_name: params[:company_name].presence,
            company_email: params[:company_email].presence
          ).generate
          @page.update!(html_content: result[:html], css_content: result[:css])
          redirect_to builder_manage_page_path(@page), notice: 'Page created & generated! Customize it in the builder.'
        else
          redirect_to builder_manage_page_path(@page), notice: 'Page created — opening builder.'
        end
      else
        @authors = Author.active.order(:full_name)
        @books = Book.includes(:author).order(:title)
        flash.now[:alert] = @page.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end

    def generate
      author = @page.author || (params[:author_id].present? ? Author.find(params[:author_id]) : nil)
      book = params[:book_id].present? ? Book.find(params[:book_id]) : nil
      result = LandingPageGenerator.new(nil,
        author: author,
        book: book,
        company_name: params[:company_name].presence,
        company_email: params[:company_email].presence
      ).generate
      @page.update!(html_content: result[:html], css_content: result[:css])
      redirect_to builder_manage_page_path(@page), notice: 'Page regenerated! Customize it in the builder.'
    end

    def edit
      @authors = Author.active.order(:full_name)
      @books = Book.includes(:author).order(:title)
    end

    def show
      respond_to do |format|
        format.json { render json: { html_content: @page.html_content, css_content: @page.css_content } }
        format.html { redirect_to builder_manage_page_path(@page) }
      end
    end

    def builder
      @standalone_mode = true
      render 'portal/landing_pages/builder', layout: false
    end

    def update
      if @page.update(page_params)
        respond_to do |format|
          format.json { render json: { success: true } }
          format.html { redirect_to manage_pages_path, notice: 'Page updated.' }
        end
      else
        respond_to do |format|
          format.json { render json: { success: false, errors: @page.errors.full_messages }, status: :unprocessable_entity }
          format.html do
            @authors = Author.active.order(:full_name)
            @books = Book.includes(:author).order(:title)
            flash.now[:alert] = @page.errors.full_messages.join(', ')
            render :edit, status: :unprocessable_entity
          end
        end
      end
    end

    def toggle_publish
      if @page.published?
        @page.unpublish!
        redirect_to manage_pages_path, notice: "\"#{@page.title}\" unpublished."
      else
        @page.publish!
        redirect_to manage_pages_path, notice: "\"#{@page.title}\" published at /pages/#{@page.slug}"
      end
    end

    def destroy
      @page.destroy
      redirect_to manage_pages_path, notice: 'Page deleted.'
    end

    private

    def set_page
      @page = LandingPage.find(params[:id])
    end

    def page_params
      params.require(:landing_page).permit(:title, :slug, :author_id, :html_content, :css_content)
    end
  end
end
