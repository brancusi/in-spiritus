# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151217220124) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "client_item_desires", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "item_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "desired",    default: false
  end

  add_index "client_item_desires", ["client_id"], name: "index_client_item_desires_on_client_id", using: :btree
  add_index "client_item_desires", ["item_id"], name: "index_client_item_desires_on_item_id", using: :btree

  create_table "client_visit_days", force: :cascade do |t|
    t.integer  "client_id",                  null: false
    t.integer  "day",                        null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "enabled",    default: false, null: false
  end

  add_index "client_visit_days", ["client_id"], name: "index_client_visit_days_on_client_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "xero_id",       limit: 255
    t.string   "nickname",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "delivery_rate",             default: 0.0,  null: false
    t.decimal  "credit_rate",               default: 0.0,  null: false
    t.integer  "terms",                     default: 14
    t.string   "company",       limit: 255
    t.string   "code",          limit: 255
    t.integer  "price_tier_id"
    t.boolean  "active",                    default: true, null: false
  end

  add_index "clients", ["code"], name: "index_clients_on_code", unique: true, using: :btree
  add_index "clients", ["price_tier_id"], name: "index_clients_on_price_tier_id", using: :btree
  add_index "clients", ["xero_id"], name: "index_clients_on_xero_id", unique: true, using: :btree

  create_table "credit_items", force: :cascade do |t|
    t.integer  "credit_id",              null: false
    t.integer  "item_id",                null: false
    t.integer  "quantity",   default: 0, null: false
    t.integer  "unit_price", default: 0, null: false
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_items", ["credit_id"], name: "index_credit_items_on_credit_id", using: :btree
  add_index "credit_items", ["item_id"], name: "index_items_on_item_id", using: :btree

  create_table "credits", force: :cascade do |t|
    t.string   "xero_id",    limit: 255
    t.integer  "client_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date",                   null: false
  end

  add_index "credits", ["client_id"], name: "index_credits_on_client_id", using: :btree

  create_table "custom_orders", force: :cascade do |t|
    t.string   "name"
    t.integer  "route_visit_id"
    t.date     "delivery_date"
    t.integer  "visit_window_id"
    t.boolean  "fullfilled"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "custom_orders", ["route_visit_id"], name: "index_custom_orders_on_route_visit_id", using: :btree
  add_index "custom_orders", ["visit_window_id"], name: "index_custom_orders_on_visit_window_id", using: :btree

  create_table "item_levels", force: :cascade do |t|
    t.integer  "start",          default: 0, null: false
    t.integer  "returns",        default: 0, null: false
    t.integer  "total",                      null: false
    t.text     "notes"
    t.integer  "day_of_week",                null: false
    t.datetime "taken_at",                   null: false
    t.integer  "item_id",                    null: false
    t.integer  "client_id",                  null: false
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "route_visit_id"
  end

  add_index "item_levels", ["client_id"], name: "index_item_levels_on_client_id", using: :btree
  add_index "item_levels", ["day_of_week"], name: "index_item_levels_on_day_of_week", using: :btree
  add_index "item_levels", ["item_id"], name: "index_item_levels_on_item_id", using: :btree
  add_index "item_levels", ["route_visit_id"], name: "index_item_levels_on_route_visit_id", using: :btree
  add_index "item_levels", ["taken_at"], name: "index_item_levels_on_taken_at", using: :btree
  add_index "item_levels", ["user_id"], name: "index_item_levels_on_user_id", using: :btree

  create_table "item_prices", force: :cascade do |t|
    t.integer  "item_id",       null: false
    t.integer  "price_tier_id", null: false
    t.decimal  "price",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "item_prices", ["item_id"], name: "index_item_prices_on_item_id", using: :btree
  add_index "item_prices", ["price_tier_id"], name: "index_item_prices_on_price_tier_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "xero_id",     limit: 255
    t.string   "sku",         limit: 255
    t.string   "description", limit: 255
    t.integer  "shelf_life"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "tag",         limit: 255, default: "product", null: false
    t.string   "code",        limit: 255,                     null: false
  end

  add_index "items", ["code"], name: "index_items_on_code", unique: true, using: :btree
  add_index "items", ["xero_id"], name: "index_items_on_xero_id", unique: true, using: :btree

  create_table "price_tiers", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.string   "xero_id"
    t.integer  "route_visit_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "purchase_orders", ["route_visit_id"], name: "index_purchase_orders_on_route_visit_id", using: :btree

  create_table "route_plans", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.date     "date"
    t.boolean  "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "route_plans", ["name"], name: "index_route_plans_on_name", unique: true, using: :btree
  add_index "route_plans", ["user_id"], name: "index_route_plans_on_user_id", using: :btree

  create_table "route_visits", force: :cascade do |t|
    t.integer  "route_plan_id",                  null: false
    t.text     "notes"
    t.integer  "arrive_at"
    t.string   "depart_at"
    t.integer  "position",                       null: false
    t.integer  "visit_window_id",                null: false
    t.string   "client_fingerprint", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.boolean  "fullfilled"
  end

  add_index "route_visits", ["route_plan_id"], name: "index_route_visits_on_route_plan_id", using: :btree
  add_index "route_visits", ["visit_window_id"], name: "index_route_visits_on_visit_window_id", using: :btree

  create_table "sales_order_items", force: :cascade do |t|
    t.integer  "sales_order_id",               null: false
    t.integer  "item_id",                      null: false
    t.integer  "quantity",       default: 0,   null: false
    t.decimal  "unit_price",     default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales_order_items", ["item_id"], name: "index_sales_order_items_on_item_id", using: :btree
  add_index "sales_order_items", ["sales_order_id"], name: "index_sales_order_items_on_sales_order_id", using: :btree

  create_table "sales_orders", force: :cascade do |t|
    t.string   "xero_id",        limit: 255
    t.integer  "client_id",                                  null: false
    t.integer  "route_visit_id"
    t.date     "delivery_date",                              null: false
    t.boolean  "invoiced",                   default: false, null: false
    t.boolean  "fullfilled",                 default: false, null: false
    t.boolean  "voided",                     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.binary   "signature"
  end

  add_index "sales_orders", ["client_id"], name: "index_sales_orders_on_client_id", using: :btree
  add_index "sales_orders", ["route_visit_id"], name: "index_sales_orders_on_route_visit_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "authentication_token",   limit: 255
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             limit: 255
    t.integer  "role"
    t.string   "last_name",              limit: 255
    t.string   "phone",                  limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "visit_windows", force: :cascade do |t|
    t.string   "address",    limit: 255, null: false
    t.string   "city",       limit: 255, null: false
    t.string   "state",      limit: 255, null: false
    t.string   "zip",        limit: 255, null: false
    t.decimal  "lat",                    null: false
    t.decimal  "lon",                    null: false
    t.text     "notes"
    t.integer  "client_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service",                null: false
    t.integer  "arrive_at",              null: false
    t.string   "depart_at",              null: false
  end

  add_index "visit_windows", ["client_id"], name: "index_visit_windows_on_client_id", using: :btree

  add_foreign_key "client_item_desires", "clients"
  add_foreign_key "client_item_desires", "items"
  add_foreign_key "client_visit_days", "clients"
  add_foreign_key "clients", "price_tiers"
  add_foreign_key "credit_items", "credits"
  add_foreign_key "credit_items", "items"
  add_foreign_key "credits", "clients"
  add_foreign_key "custom_orders", "route_visits"
  add_foreign_key "custom_orders", "visit_windows"
  add_foreign_key "item_levels", "clients"
  add_foreign_key "item_levels", "items"
  add_foreign_key "item_levels", "route_visits"
  add_foreign_key "item_levels", "users"
  add_foreign_key "item_prices", "price_tiers"
  add_foreign_key "purchase_orders", "route_visits"
  add_foreign_key "route_plans", "users"
  add_foreign_key "route_visits", "route_plans"
  add_foreign_key "route_visits", "visit_windows"
  add_foreign_key "sales_order_items", "items"
  add_foreign_key "sales_order_items", "sales_orders"
  add_foreign_key "sales_orders", "clients"
  add_foreign_key "sales_orders", "route_visits"
  add_foreign_key "visit_windows", "clients"
end