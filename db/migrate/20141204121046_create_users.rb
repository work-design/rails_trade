class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string   "name",  null: false
      t.string   "email", null: false
      t.string   "password_digest", null: false
      t.string   "confirm_token"
      t.datetime "confirm_sent_at"
      t.integer  "logins_count", default: 0
      t.datetime "current_login_at"
      t.datetime "last_login_at"
      t.string   "current_login_ip"
      t.string   "last_login_ip"

      t.string   "avatar"

      t.integer  "role_id"
      t.datetime "created_at",                                null: false
      t.datetime "updated_at",                                null: false
    end

    create_table "roles", force: true do |t|
      t.string "name",       null: false
      t.string "title",        null: false
      t.text   "description",  null: false
      t.text   "the_role",     null: false
    end

    create_table :user_promotes do |t|
      t.integer :user_id
      t.integer :promote_id
    end


  end
end
