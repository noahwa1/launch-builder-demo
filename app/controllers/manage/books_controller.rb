module Manage
  class BooksController < BaseController
    before_action :set_book, only: [:show, :edit, :update, :destroy]

    def index
      @books = Book.includes(:author, :publisher).order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
      @royalty_rates = @book.royalty_rates.order(effective_from: :desc)
      @recent_statements = @book.royalty_statements.includes(:royalty_payment).order(created_at: :desc).limit(10)
    end

    def new
      @book = Book.new
      @authors = Author.order(:full_name)
      @publishers = Publisher.order(:name)
    end

    def create
      @book = Book.new(book_params)
      if @book.save
        redirect_to manage_book_path(@book), notice: 'Book created.'
      else
        @authors = Author.order(:full_name)
        @publishers = Publisher.order(:name)
        flash.now[:alert] = @book.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @authors = Author.order(:full_name)
      @publishers = Publisher.order(:name)
    end

    def update
      if @book.update(book_params)
        redirect_to manage_book_path(@book), notice: 'Book updated.'
      else
        @authors = Author.order(:full_name)
        @publishers = Publisher.order(:name)
        flash.now[:alert] = @book.errors.full_messages.join(', ')
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @book.destroy
      redirect_to manage_books_path, notice: 'Book deleted.'
    end

    private

    def set_book
      @book = Book.find(params[:id])
    end

    def book_params
      params.require(:book).permit(:title, :isbn, :description, :cover, :release_date, :author_id, :publisher_id)
    end
  end
end
