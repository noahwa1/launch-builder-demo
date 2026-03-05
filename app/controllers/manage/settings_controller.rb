module Manage
  class SettingsController < BaseController
    def index
      @total_users = User.count
      @admin_count = User.admin.count
      @creator_count = User.creator.count
      @campaign_count = Campaign.count
      @book_count = Book.count
      @author_count = Author.count
      @db_adapter = ActiveRecord::Base.connection.adapter_name
    end
  end
end
