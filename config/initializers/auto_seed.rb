Rails.application.config.after_initialize do
  if defined?(User) && ActiveRecord::Base.connection.table_exists?('users') && User.count == 0
    Rails.logger.info "No users found — running seeds..."
    Rails.application.load_seed
  end
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  # DB not ready yet, skip
end
