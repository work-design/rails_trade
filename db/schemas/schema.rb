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

ActiveRecord::Schema.define(version: 20141013144836) do

  create_table "areas", force: true do |t|
    t.string  "name",      limit: 255, default: ""
    t.string  "province",  limit: 255
    t.string  "city",      limit: 255
    t.string  "district",  limit: 255
    t.integer "depth",     limit: 4,   default: 0
    t.integer "parent_id", limit: 4
    t.integer "lft",       limit: 4
    t.integer "rgt",       limit: 4
  end

  create_table "good_items", force: true do |t|
    t.integer "good_id", limit: 4
    t.integer "item_id", limit: 4
    t.string  "picture", limit: 255
  end

  create_table "goods", force: true do |t|
    t.boolean  "published",   limit: 1,     default: true
    t.float    "price",       limit: 24,    default: 0.0
    t.string   "sku",         limit: 255
    t.integer  "position",    limit: 4,     default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "overview",    limit: 65535
    t.float    "price_lower", limit: 24,    default: 0.0
    t.string   "buy_link",    limit: 255
    t.integer  "sales_count", limit: 4,     default: 0
    t.integer  "provider_id", limit: 4
    t.datetime "start_at"
    t.datetime "finish_at"
    t.integer  "promote_id",  limit: 4
    t.string   "name",        limit: 255,   default: ""
    t.string   "logo",        limit: 255
    t.integer  "user_id",     limit: 4
  end

  create_table "items", force: true do |t|
    t.string   "name",           limit: 255
    t.string   "picture",        limit: 255
    t.integer  "praise",         limit: 4,     default: 0
    t.datetime "updated_at"
    t.integer  "list_id",        limit: 4
    t.text     "content",        limit: 65535
    t.string   "list_name",      limit: 255
    t.string   "type",           limit: 255
    t.integer  "parent_id",      limit: 4
    t.integer  "lft",            limit: 4
    t.integer  "rgt",            limit: 4
    t.integer  "children_count", limit: 4,     default: 0
    t.integer  "depth",          limit: 4,     default: 0
  end

  add_index "items", ["list_id"], name: "index_items_on_list_id", using: :btree

  create_table "lists", force: true do |t|
    t.string  "name",        limit: 255, default: ""
    t.integer "items_count", limit: 4,   default: 0
    t.integer "position",    limit: 4,   default: 0
    t.string  "type",        limit: 255
    t.integer "status",      limit: 4,   default: 0
  end

  create_table "orders", force: true do |t|
    t.integer  "user_id",     limit: 4,              null: false
    t.float    "total_price", limit: 24
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "good_id",     limit: 4
    t.integer  "quantity",    limit: 4,  default: 1
    t.time     "order_at"
    t.date     "order_on"
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "photos", force: true do |t|
    t.string   "title",          limit: 255
    t.string   "description",    limit: 255
    t.integer  "user_id",        limit: 4
    t.string   "photo",          limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "imageable_id",   limit: 4
    t.string   "imageable_type", limit: 255
    t.integer  "position",       limit: 4,   default: 0
  end

  create_table "promotes", force: true do |t|
    t.string "name", limit: 255
  end

  create_table "providers", force: true do |t|
    t.string   "name",        limit: 255
    t.string   "address",     limit: 255
    t.string   "service_tel", limit: 255
    t.string   "logo",        limit: 255
    t.integer  "area_id",     limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id",     limit: 4
    t.string   "service_qq",  limit: 255
  end

  create_table "roles", force: true do |t|
    t.string "name",        limit: 255,   null: false
    t.string "title",       limit: 255,   null: false
    t.text   "description", limit: 65535, null: false
    t.text   "the_role",    limit: 65535, null: false
  end

  create_table "sales", force: true do |t|
    t.integer "good_id", limit: 4
    t.integer "add_id",  limit: 4
  end

  create_table "sections", force: true do |t|
    t.string  "name",        limit: 255
    t.integer "sort_id",     limit: 4
    t.integer "position",    limit: 4,   default: 0
    t.integer "add_sort_id", limit: 4
  end

  create_table "stars", force: true do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "lovable_id",   limit: 4
    t.string   "lovable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name",           limit: 255
    t.string   "picture",        limit: 255
    t.integer  "praise",         limit: 4,     default: 0
    t.datetime "updated_at"
    t.integer  "sort_id",        limit: 4
    t.text     "content",        limit: 65535
    t.string   "sort_name",      limit: 255
    t.string   "type",           limit: 255
    t.integer  "parent_id",      limit: 4
    t.integer  "lft",            limit: 4
    t.integer  "rgt",            limit: 4
    t.integer  "children_count", limit: 4,     default: 0
    t.integer  "depth",          limit: 4,     default: 0
  end

  create_table "users", force: true do |t|
    t.string   "email",            limit: 255, default: "", null: false
    t.string   "password_digest",  limit: 255, default: "", null: false
    t.string   "confirm_token",    limit: 255
    t.datetime "confirm_sent_at"
    t.integer  "logins_count",     limit: 4,   default: 0
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip", limit: 255
    t.string   "last_login_ip",    limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "avatar",           limit: 255
    t.string   "name",             limit: 255, default: ""
    t.integer  "role_id",          limit: 4
  end

  add_index "users", ["confirm_token"], name: "index_users_on_confirm_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
