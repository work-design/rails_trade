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


end
