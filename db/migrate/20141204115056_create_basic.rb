class CreateBasic < ActiveRecord::Migration
  def change

    create_table "contributions", force: true do |t|
      t.integer "user_id"
      t.integer "contribute_id"
      t.string  "contribute_type"
    end

    create_table :administrators do |t|
      t.integer :user_id
      t.integer :admin_id
      t.string :admin_type
    end

    create_table "stars", force: true do |t|
      t.integer  "user_id"
      t.integer  "lovable_id"
      t.string   "lovable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "photos", force: true do |t|
      t.string   "title"
      t.string   "description"
      t.string   "photo"
      t.integer  "imageable_id"
      t.string   "imageable_type"
      t.integer  "position", default: 0
      t.datetime "created_at",                             null: false
      t.datetime "updated_at",                             null: false
    end

    create_table "areas", force: true do |t|
      t.string  "name",     null: false
      t.string  "province"
      t.string  "city"
      t.string  "district"
      t.integer "parent_id"
    end

  end
end
