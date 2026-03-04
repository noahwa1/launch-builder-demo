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

ActiveRecord::Schema[7.2].define(version: 2026_03_04_100004) do
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

  create_table "landing_pages", force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.string "title"
    t.text "html_content"
    t.text "css_content"
    t.boolean "published", default: false
    t.string "slug"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_landing_pages_on_campaign_id", unique: true
    t.index ["slug"], name: "index_landing_pages_on_slug", unique: true
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
    t.index ["account_type", "account_id"], name: "index_users_on_account_type_and_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "campaign_assets", "campaigns"
  add_foreign_key "campaigns", "authors"
  add_foreign_key "campaigns", "books"
  add_foreign_key "campaigns", "submissions"
  add_foreign_key "checklist_items", "campaigns"
  add_foreign_key "landing_pages", "campaigns"
end
