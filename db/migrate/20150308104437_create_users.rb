class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
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
end
