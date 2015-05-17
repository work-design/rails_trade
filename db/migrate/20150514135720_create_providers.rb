class CreateProviders < ActiveRecord::Migration
  def change

    create_table "providers" do |t|
      t.string   "name",        limit: 255
      t.string   "logo",        limit: 255
      t.string   "address",     limit: 255
      t.integer  "area_id",     limit: 4
      t.datetime "created_at",              null: false
      t.datetime "updated_at",              null: false
      t.string   "service_tel", limit: 255
      t.string   "service_qq",  limit: 255
    end

  end
end
