class CreateProviders < ActiveRecord::Migration
  def change

    create_table :providers do |t|
      t.string   "name",        limit: 255
      t.string   "logo_url",        limit: 255
      t.integer  "area_id"
      t.string   "address",     limit: 255
      t.string   "service_tel", limit: 255
      t.string   "service_qq",  limit: 255
      t.timestamps
    end

  end
end
