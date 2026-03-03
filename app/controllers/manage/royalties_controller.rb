module Manage
  class RoyaltiesController < BaseController
    before_action :set_payment, only: [:show, :mark_paid]

    def index
      @payments = RoyaltyPayment.includes(:author).recent.page(params[:page]).per(15)
      @authors = Author.active.order(:last_name)
    end

    def show
      @statements = @payment.royalty_statements.includes(:book)
    end

    def new
      @payment = RoyaltyPayment.new
      @authors = Author.active.order(:last_name)
    end

    def create
      @payment = RoyaltyPayment.new(payment_params)
      if @payment.save
        PortalMailer.payment_processed(@payment).deliver_later if @payment.paid?
        redirect_to manage_royalty_path(@payment), notice: 'Payment created.'
      else
        @authors = Author.active.order(:last_name)
        render :new
      end
    end

    def mark_paid
      @payment.mark_paid!(params[:reference])
      PortalMailer.payment_processed(@payment).deliver_later
      redirect_to manage_royalty_path(@payment), notice: 'Payment marked as paid.'
    end

    def rates
      @rates = RoyaltyRate.includes(:author, :book).order(created_at: :desc).page(params[:page]).per(15)
    end

    def new_rate
      @rate = RoyaltyRate.new
      @authors = Author.active.order(:last_name)
    end

    def create_rate
      @rate = RoyaltyRate.new(rate_params)
      if @rate.save
        redirect_to rates_manage_royalties_path, notice: 'Rate created.'
      else
        @authors = Author.active.order(:last_name)
        render :new_rate
      end
    end

    private

    def set_payment
      @payment = RoyaltyPayment.find(params[:id])
    end

    def payment_params
      params.require(:royalty_payment).permit(
        :author_id, :amount, :currency, :status, :period_start, :period_end, :reference, :notes,
        royalty_statements_attributes: [:id, :book_id, :units_sold, :gross_revenue, :royalty_rate, :royalty_amount, :_destroy]
      )
    end

    def rate_params
      params.require(:royalty_rate).permit(:author_id, :book_id, :rate, :effective_from, :effective_to)
    end
  end
end
