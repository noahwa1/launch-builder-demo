module Portal
  class RoyaltiesController < BaseController
    def index
      @payments = current_author.royalty_payments.recent.page(params[:page]).per(10)
      @rates = current_author.royalty_rates.active.includes(:book)
      @total_earned = current_author.royalty_payments.where(status: :paid).sum(:amount)
      @pending_amount = current_author.royalty_payments.where(status: [:pending, :processing]).sum(:amount)
    end

    def show
      @payment = current_author.royalty_payments.find(params[:id])
      @statements = @payment.royalty_statements.includes(:book)

      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "royalty-statement-#{@payment.id}",
                 template: 'portal/royalties/show',
                 layout: 'pdf'
        end
      end
    end
  end
end
