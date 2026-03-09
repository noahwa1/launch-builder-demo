# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_03_10_900002) do
  create_table "admin_deliverables", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "created_by", null: false
    t.string "title", null: false
    t.text "description"
    t.string "category", null: false
    t.string "file"
    t.integer "status", default: 0
    t.text "creator_notes"
    t.integer "revision_count", default: 0
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_admin_deliverables_on_campaign_id"
    t.index ["created_by"], name: "index_admin_deliverables_on_created_by"
    t.index ["status"], name: "index_admin_deliverables_on_status"
  end

  create_table "authors", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "full_name"
    t.text "description"
    t.string "image"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.string "isbn"
    t.text "description"
    t.string "cover"
    t.date "release_date"
    t.integer "author_id", null: false
    t.integer "publisher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
    t.index ["publisher_id"], name: "index_books_on_publisher_id"
  end

  create_table "campaign_activities", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "user_id"
    t.string "action", null: false
    t.string "subject_type"
    t.integer "subject_id"
    t.json "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "created_at"], name: "index_campaign_activities_on_campaign_id_and_created_at"
    t.index ["campaign_id"], name: "index_campaign_activities_on_campaign_id"
    t.index ["subject_type", "subject_id"], name: "index_campaign_activities_on_subject_type_and_subject_id"
    t.index ["user_id"], name: "index_campaign_activities_on_user_id"
  end

  create_table "campaign_assets", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "asset_type", null: false
    t.string "file"
    t.string "original_filename"
    t.integer "status", default: 0, null: false
    t.text "admin_notes"
    t.integer "reviewed_by"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "asset_type"], name: "index_campaign_assets_on_campaign_id_and_asset_type"
    t.index ["campaign_id"], name: "index_campaign_assets_on_campaign_id"
    t.index ["status"], name: "index_campaign_assets_on_status"
  end

  create_table "campaigns", force: :cascade do |t|
    t.integer "submission_id", null: false
    t.integer "author_id", null: false
    t.integer "book_id"
    t.string "title", null: false
    t.integer "status", default: 0, null: false
    t.string "signed_editions_url"
    t.text "bookplate_address"
    t.string "bookplate_design"
    t.string "management_emails"
    t.boolean "facebook_access", default: false
    t.boolean "instagram_access", default: false
    t.boolean "tiktok_access", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "onboarding_completed_at"
    t.string "example_category"
    t.boolean "personal_videos_enabled", default: false
    t.text "brief"
    t.date "launch_date"
    t.date "content_deadline"
    t.date "review_deadline"
    t.text "ad_access_notes"
    t.string "campaign_type", default: "full"
    t.boolean "landing_page_enabled", default: true
    t.boolean "asset_uploads_enabled", default: true
    t.boolean "deliverables_enabled", default: true
    t.boolean "live_events_enabled", default: true
    t.boolean "social_tools_enabled", default: true
    t.boolean "royalties_enabled", default: true
    t.integer "phase", default: 0, null: false
    t.boolean "fan_crm_enabled", default: true
    t.index ["author_id"], name: "index_campaigns_on_author_id"
    t.index ["book_id"], name: "index_campaigns_on_book_id"
    t.index ["status"], name: "index_campaigns_on_status"
    t.index ["submission_id"], name: "index_campaigns_on_submission_id", unique: true
  end

  create_table "checklist_items", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "category", null: false
    t.integer "status", default: 0, null: false
    t.integer "position", default: 0
    t.boolean "optional", default: false
    t.string "key"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "category"], name: "index_checklist_items_on_campaign_id_and_category"
    t.index ["campaign_id", "key"], name: "index_checklist_items_on_campaign_id_and_key", unique: true
    t.index ["campaign_id"], name: "index_checklist_items_on_campaign_id"
  end

  create_table "contact_events", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.string "event_type", null: false
    t.string "subject"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_contact_events_on_contact_id"
    t.index ["created_at"], name: "index_contact_events_on_created_at"
    t.index ["event_type"], name: "index_contact_events_on_event_type"
  end

  create_table "contact_tags", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.integer "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id", "tag_id"], name: "index_contact_tags_on_contact_id_and_tag_id", unique: true
    t.index ["contact_id"], name: "index_contact_tags_on_contact_id"
    t.index ["tag_id"], name: "index_contact_tags_on_tag_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "source"
    t.integer "source_id"
    t.json "metadata"
    t.integer "score", default: 0
    t.integer "status", default: 0
    t.datetime "last_activity_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "email"], name: "index_contacts_on_campaign_id_and_email", unique: true
    t.index ["campaign_id"], name: "index_contacts_on_campaign_id"
    t.index ["score"], name: "index_contacts_on_score"
    t.index ["status"], name: "index_contacts_on_status"
  end

  create_table "creator_confirmations", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "section", null: false
    t.integer "confirmed_by", null: false
    t.datetime "confirmed_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "section"], name: "index_creator_confirmations_on_campaign_id_and_section", unique: true
    t.index ["campaign_id"], name: "index_creator_confirmations_on_campaign_id"
  end

  create_table "deliverable_notes", force: :cascade do |t|
    t.integer "admin_deliverable_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_deliverable_id"], name: "index_deliverable_notes_on_admin_deliverable_id"
    t.index ["user_id"], name: "index_deliverable_notes_on_user_id"
  end

  create_table "drip_campaigns", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "name", null: false
    t.string "trigger_event", default: "receipt_submitted"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_drip_campaigns_on_campaign_id"
  end

  create_table "drip_enrollments", force: :cascade do |t|
    t.integer "drip_campaign_id", null: false
    t.integer "contact_id", null: false
    t.integer "current_step", default: 0
    t.integer "status", default: 0
    t.datetime "next_send_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_drip_enrollments_on_contact_id"
    t.index ["drip_campaign_id", "contact_id"], name: "index_drip_enrollments_on_drip_campaign_id_and_contact_id", unique: true
    t.index ["drip_campaign_id"], name: "index_drip_enrollments_on_drip_campaign_id"
    t.index ["next_send_at"], name: "index_drip_enrollments_on_next_send_at"
  end

  create_table "drip_messages", force: :cascade do |t|
    t.integer "drip_enrollment_id", null: false
    t.integer "drip_step_id", null: false
    t.integer "contact_id", null: false
    t.integer "status", default: 0
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_drip_messages_on_contact_id"
    t.index ["drip_enrollment_id"], name: "index_drip_messages_on_drip_enrollment_id"
    t.index ["drip_step_id"], name: "index_drip_messages_on_drip_step_id"
  end

  create_table "drip_steps", force: :cascade do |t|
    t.integer "drip_campaign_id", null: false
    t.integer "position", default: 0
    t.integer "delay_hours", default: 0
    t.string "channel", default: "email"
    t.string "subject"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drip_campaign_id", "position"], name: "index_drip_steps_on_drip_campaign_id_and_position"
    t.index ["drip_campaign_id"], name: "index_drip_steps_on_drip_campaign_id"
  end

  create_table "landing_pages", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "title"
    t.text "html_content"
    t.text "css_content"
    t.boolean "published", default: false
    t.string "slug"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "build_requested", default: false
    t.datetime "build_requested_at"
    t.boolean "notify_on_submission", default: true
    t.integer "author_id"
    t.string "wizard_template"
    t.index ["author_id"], name: "index_landing_pages_on_author_id"
    t.index ["campaign_id"], name: "index_landing_pages_on_campaign_id", unique: true
    t.index ["slug"], name: "index_landing_pages_on_slug", unique: true
  end

  create_table "live_events", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "embed_url"
    t.string "stream_platform"
    t.integer "status", default: 0, null: false
    t.datetime "scheduled_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_live_events_on_campaign_id"
    t.index ["status"], name: "index_live_events_on_status"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "campaign_id", null: false
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "body"
    t.string "url"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_notifications_on_campaign_id"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "page_submissions", force: :cascade do |t|
    t.integer "landing_page_id", null: false
    t.string "form_type"
    t.json "data"
    t.string "receipt"
    t.string "email"
    t.string "ip_address"
    t.string "user_agent"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_page_submissions_on_email"
    t.index ["landing_page_id"], name: "index_page_submissions_on_landing_page_id"
    t.index ["status"], name: "index_page_submissions_on_status"
  end

  create_table "personal_videos", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "page_submission_id", null: false
    t.string "file"
    t.integer "status", default: 0, null: false
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_personal_videos_on_campaign_id"
    t.index ["page_submission_id"], name: "index_personal_videos_on_page_submission_id", unique: true
    t.index ["status"], name: "index_personal_videos_on_status"
  end

  create_table "portal_messages", force: :cascade do |t|
    t.integer "sender_id", null: false
    t.integer "thread_owner_id", null: false
    t.integer "submission_id"
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sender_id"], name: "index_portal_messages_on_sender_id"
    t.index ["submission_id"], name: "index_portal_messages_on_submission_id"
    t.index ["thread_owner_id"], name: "index_portal_messages_on_thread_owner_id"
  end

  create_table "publishers", force: :cascade do |t|
    t.string "name", null: false
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "referral_codes", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.integer "campaign_id", null: false
    t.string "code", null: false
    t.integer "referral_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_referral_codes_on_campaign_id"
    t.index ["code"], name: "index_referral_codes_on_code", unique: true
    t.index ["contact_id"], name: "index_referral_codes_on_contact_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.integer "referral_code_id", null: false
    t.integer "referred_contact_id", null: false
    t.integer "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_referrals_on_campaign_id"
    t.index ["referral_code_id", "referred_contact_id"], name: "index_referrals_on_referral_code_id_and_referred_contact_id", unique: true
    t.index ["referral_code_id"], name: "index_referrals_on_referral_code_id"
    t.index ["referred_contact_id"], name: "index_referrals_on_referred_contact_id"
  end

  create_table "royalty_payments", force: :cascade do |t|
    t.integer "author_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "USD"
    t.integer "status", default: 0, null: false
    t.date "period_start", null: false
    t.date "period_end", null: false
    t.string "reference"
    t.text "notes"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_royalty_payments_on_author_id"
    t.index ["status"], name: "index_royalty_payments_on_status"
  end

  create_table "royalty_rates", force: :cascade do |t|
    t.integer "author_id", null: false
    t.integer "book_id"
    t.decimal "rate", precision: 5, scale: 4, null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_royalty_rates_on_author_id"
    t.index ["book_id"], name: "index_royalty_rates_on_book_id"
  end

  create_table "royalty_statements", force: :cascade do |t|
    t.integer "royalty_payment_id", null: false
    t.integer "book_id", null: false
    t.integer "units_sold", default: 0
    t.decimal "gross_revenue", precision: 10, scale: 2
    t.decimal "royalty_rate", precision: 5, scale: 4
    t.decimal "royalty_amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_royalty_statements_on_book_id"
    t.index ["royalty_payment_id"], name: "index_royalty_statements_on_royalty_payment_id"
  end

  create_table "scheduled_posts", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "platform", null: false
    t.string "category"
    t.text "body", null: false
    t.datetime "scheduled_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["campaign_id", "scheduled_at"], name: "index_scheduled_posts_on_campaign_id_and_scheduled_at"
    t.index ["campaign_id"], name: "index_scheduled_posts_on_campaign_id"
    t.index ["status"], name: "index_scheduled_posts_on_status"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "author_id", null: false
    t.integer "submitted_by", null: false
    t.string "title", null: false
    t.string "isbn"
    t.text "description"
    t.string "cover"
    t.date "release_date"
    t.string "genre"
    t.integer "status", default: 0, null: false
    t.text "admin_notes"
    t.integer "reviewed_by"
    t.datetime "submitted_at"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_submissions_on_author_id"
    t.index ["isbn"], name: "index_submissions_on_isbn", unique: true
    t.index ["status"], name: "index_submissions_on_status"
    t.index ["submitted_by"], name: "index_submissions_on_submitted_by"
  end

  create_table "tags", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "name", null: false
    t.string "color", default: "#003262"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "name"], name: "index_tags_on_campaign_id_and_name", unique: true
    t.index ["campaign_id"], name: "index_tags_on_campaign_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.string "account_type"
    t.integer "account_id"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.boolean "email_on_notification", default: true
    t.index ["account_type", "account_id"], name: "index_users_on_account_type_and_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "admin_deliverables", "campaigns"
  add_foreign_key "campaign_activities", "campaigns"
  add_foreign_key "campaign_activities", "users"
  add_foreign_key "campaign_assets", "campaigns"
  add_foreign_key "campaigns", "authors"
  add_foreign_key "campaigns", "books"
  add_foreign_key "campaigns", "submissions"
  add_foreign_key "checklist_items", "campaigns"
  add_foreign_key "contact_events", "contacts"
  add_foreign_key "contact_tags", "contacts"
  add_foreign_key "contact_tags", "tags"
  add_foreign_key "contacts", "campaigns"
  add_foreign_key "creator_confirmations", "campaigns"
  add_foreign_key "deliverable_notes", "admin_deliverables"
  add_foreign_key "deliverable_notes", "users"
  add_foreign_key "drip_campaigns", "campaigns"
  add_foreign_key "drip_enrollments", "contacts"
  add_foreign_key "drip_enrollments", "drip_campaigns"
  add_foreign_key "drip_messages", "contacts"
  add_foreign_key "drip_messages", "drip_enrollments"
  add_foreign_key "drip_messages", "drip_steps"
  add_foreign_key "drip_steps", "drip_campaigns"
  add_foreign_key "landing_pages", "campaigns", on_delete: :nullify
  add_foreign_key "live_events", "campaigns"
  add_foreign_key "notifications", "campaigns"
  add_foreign_key "notifications", "users"
  add_foreign_key "page_submissions", "landing_pages"
  add_foreign_key "personal_videos", "campaigns"
  add_foreign_key "personal_videos", "page_submissions"
  add_foreign_key "referral_codes", "campaigns"
  add_foreign_key "referral_codes", "contacts"
  add_foreign_key "referrals", "campaigns"
  add_foreign_key "referrals", "contacts", column: "referred_contact_id"
  add_foreign_key "referrals", "referral_codes"
  add_foreign_key "scheduled_posts", "campaigns"
  add_foreign_key "tags", "campaigns"
end
