module Portal
  class SalesController < BaseController
    def index
      @books = current_author.books
      @selected_book = params[:book_id].present? ? @books.find(params[:book_id]) : @books.first

      # Mock sales data for demo — will connect to Core API when ported
      @monthly_sales = generate_mock_sales(@selected_book) if @selected_book
      @total_units = @monthly_sales&.sum { |m| m[:units] } || 0
      @total_revenue = @monthly_sales&.sum { |m| m[:revenue] } || 0
    end

    private

    def generate_mock_sales(book)
      12.downto(1).map do |months_ago|
        date = months_ago.months.ago.beginning_of_month
        units = rand(50..500)
        {
          month: date.strftime('%b %Y'),
          units: units,
          revenue: (units * rand(8.0..25.0)).round(2)
        }
      end
    end
  end
end
