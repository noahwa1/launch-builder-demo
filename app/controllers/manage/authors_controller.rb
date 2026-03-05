module Manage
  class AuthorsController < BaseController
    before_action :set_author, only: [:show, :edit, :update, :destroy, :toggle_status]

    def index
      @authors = Author.order(created_at: :desc)
      @authors = @authors.where(status: params[:status]) if params[:status].present?
      @authors = @authors.page(params[:page]).per(20)
    end

    def show
      @campaigns = @author.campaigns.includes(:checklist_items).order(created_at: :desc)
      @books = @author.books.includes(:publisher)
    end

    def new
      @author = Author.new
    end

    def create
      @author = Author.new(author_params)
      if @author.save
        redirect_to manage_author_path(@author), notice: 'Author created.'
      else
        flash.now[:alert] = @author.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @author.update(author_params)
        redirect_to manage_author_path(@author), notice: 'Author updated.'
      else
        flash.now[:alert] = @author.errors.full_messages.join(', ')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @author.destroy
      redirect_to manage_authors_path, notice: 'Author deleted.'
    end

    def toggle_status
      new_status = @author.active? ? :inactive : :active
      @author.update!(status: new_status)
      redirect_to manage_author_path(@author), notice: "Author marked as #{new_status}."
    end

    private

    def set_author
      @author = Author.find(params[:id])
    end

    def author_params
      params.require(:author).permit(:first_name, :last_name, :description, :image, :status)
    end
  end
end
