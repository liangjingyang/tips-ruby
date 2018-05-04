# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180406000006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "user_id"
    t.string "action_name"
    t.string "controller_name"
    t.jsonb "params"
    t.datetime "updated_at", null: false
  end

  create_table "balances", force: :cascade do |t|
    t.integer "user_id"
    t.integer "fee_rate"
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_sales", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_profit", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_withdraw", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "boxes", force: :cascade do |t|
    t.integer "user_id"
    t.string "user_name"
    t.string "user_image"
    t.string "image"
    t.string "post_image"
    t.string "title"
    t.string "state", default: "created", null: false
    t.string "number"
    t.string "period_type"
    t.integer "period"
    t.decimal "price", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "count_on_hand", default: 0, null: false
    t.boolean "tracking_inventory", default: false, null: false
    t.integer "sales", default: 0
    t.boolean "approved", default: false, null: false
    t.integer "approved_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "followings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "box_id"
    t.string "seller_name"
    t.string "seller_image"
    t.datetime "started_at"
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "number"
    t.string "prepay_id"
    t.string "transaction_id"
    t.integer "buyer_id"
    t.integer "seller_id"
    t.string "buyer_name"
    t.string "seller_name"
    t.string "buyer_image"
    t.string "seller_image"
    t.integer "box_id"
    t.string "box_title"
    t.integer "following_id"
    t.integer "quantity"
    t.decimal "price", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "fee_rate"
    t.decimal "fee", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "profit", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.string "reason"
    t.string "client_payment_result"
    t.string "state", default: "pending", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer "box_id"
    t.text "content"
    t.jsonb "images"
    t.jsonb "voices"
    t.jsonb "videos"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recommends", force: :cascade do |t|
    t.integer "box_id"
    t.integer "weight", default: 0, null: false
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "unionid"
    t.string "openid"
    t.string "session_key"
    t.string "app_id"
    t.string "language"
    t.string "country"
    t.string "province"
    t.string "city"
    t.string "gender"
    t.string "encrypted_password", default: "", null: false
    t.string "encrypted_captcha", default: "", null: false
    t.string "image"
    t.datetime "deleted_at"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["openid"], name: "index_users_on_openid", unique: true
  end

  create_table "withdraws", force: :cascade do |t|
    t.integer "user_id"
    t.string "number"
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "state", default: "applied", null: false
    t.string "reason"
    t.text "comment"
    t.datetime "applied_at"
    t.datetime "approved_at"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.datetime "released_at"
    t.datetime "canceled_at"
    t.integer "approved_by"
    t.integer "released_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
