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

ActiveRecord::Schema.define(version: 20150130123018) do

  create_table "administrators", force: :cascade do |t|
    t.integer "user_id",    limit: 4
    t.integer "admin_id",   limit: 4
    t.string  "admin_type", limit: 255
  end

  create_table "areas", force: :cascade do |t|
    t.string  "name",      limit: 255, null: false
    t.string  "province",  limit: 255
    t.string  "city",      limit: 255
    t.string  "district",  limit: 255
    t.integer "parent_id", limit: 4
  end

  create_table "contributions", force: :cascade do |t|
    t.integer "user_id",         limit: 4
    t.integer "contribute_id",   limit: 4
    t.string  "contribute_type", limit: 255
  end

  create_table "good_items", force: :cascade do |t|
    t.integer "good_id",  limit: 4
    t.integer "item_id",  limit: 4
    t.string  "picture",  limit: 255
    t.integer "position", limit: 4,   default: 0
    t.integer "list_id",  limit: 4
  end

  create_table "good_partners", force: :cascade do |t|
    t.integer "good_id",    limit: 4
    t.integer "partner_id", limit: 4
  end

  create_table "good_produces", force: :cascade do |t|
    t.integer  "good_id",    limit: 4
    t.integer  "produce_id", limit: 4
    t.string   "picture",    limit: 255
    t.integer  "position",   limit: 4,   default: 0
    t.datetime "start_at"
    t.datetime "finish_at"
  end

  create_table "goods", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "logo",        limit: 255
    t.text     "overview",    limit: 65535
    t.integer  "provider_id", limit: 4
    t.string   "sku",         limit: 255
    t.float    "price",       limit: 24,    default: 9999.0
    t.integer  "sales_count", limit: 4,     default: 0
    t.boolean  "published",   limit: 1,     default: true
    t.integer  "promote_id",  limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "item_children", force: :cascade do |t|
    t.integer "item_id",  limit: 4
    t.integer "child_id", limit: 4
    t.integer "position", limit: 4, default: 0
  end

  create_table "item_parents", force: :cascade do |t|
    t.integer "item_id",   limit: 4
    t.integer "parent_id", limit: 4
    t.integer "position",  limit: 4, default: 0
  end

  create_table "items", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "picture",        limit: 255
    t.integer  "list_id",        limit: 4
    t.string   "list_name",      limit: 255
    t.text     "content",        limit: 65535
    t.string   "type",           limit: 255
    t.integer  "status",         limit: 4,     default: 0
    t.integer  "node_type",      limit: 4
    t.integer  "children_count", limit: 4,     default: 0
    t.datetime "updated_at"
  end

  create_table "lists", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.integer "items_count", limit: 4,   default: 0
    t.integer "position",    limit: 4,   default: 0
    t.integer "kind",        limit: 4
  end

  create_table "order_shipments", force: :cascade do |t|
    t.integer "order_id",    limit: 4
    t.integer "shipment_id", limit: 4
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",     limit: 4,              null: false
    t.integer  "good_id",     limit: 4
    t.float    "price",       limit: 24
    t.integer  "quantity",    limit: 4,  default: 1
    t.float    "total_price", limit: 24
    t.time     "order_at"
    t.date     "order_on"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer "user_id",     limit: 4
    t.integer "order_id",    limit: 4
    t.float   "total_price", limit: 24
  end

  create_table "photos", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "description",    limit: 255
    t.string   "photo",          limit: 255
    t.integer  "imageable_id",   limit: 4
    t.string   "imageable_type", limit: 255
    t.integer  "position",       limit: 4,   default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "produces", force: :cascade do |t|
    t.string   "product",    limit: 255
    t.string   "name",       limit: 255
    t.text     "content",    limit: 65535
    t.datetime "start_at"
    t.datetime "finish_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promotes", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "price_reduce", limit: 4
    t.datetime "start_at"
    t.datetime "finish_at"
  end

  create_table "providers", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "logo",        limit: 255
    t.string   "address",     limit: 255
    t.integer  "area_id",     limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "service_tel", limit: 255
    t.string   "service_qq",  limit: 255
  end

  create_table "roles", force: :cascade do |t|
    t.string "name",        limit: 255,   null: false
    t.string "title",       limit: 255,   null: false
    t.text   "description", limit: 65535, null: false
    t.text   "the_role",    limit: 65535, null: false
  end

  create_table "shipments", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "area_id", limit: 4
    t.string  "address", limit: 255
  end

  create_table "stars", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "lovable_id",   limit: 4
    t.string   "lovable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_promotes", force: :cascade do |t|
    t.integer "user_id",    limit: 4
    t.integer "promote_id", limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",             limit: 255,             null: false
    t.string   "email",            limit: 255,             null: false
    t.string   "password_digest",  limit: 255,             null: false
    t.string   "confirm_token",    limit: 255
    t.datetime "confirm_sent_at"
    t.integer  "logins_count",     limit: 4,   default: 0
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip", limit: 255
    t.string   "last_login_ip",    limit: 255
    t.string   "avatar",           limit: 255
    t.integer  "role_id",          limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

end
