class CreateItems < ActiveRecord::Migration
  def change

    create_table "items", force: true do |t|
      t.string   "name"
      t.string   "picture"
      t.integer  "list_id"
      t.string   "list_name"
      t.text     "content"
      t.string   "type"
      t.integer  "status", default: 0
      t.integer :node_type
      t.integer  "children_count", default: 0
      t.datetime "updated_at"
    end

    create_table "lists", force: true do |t|
      t.string  "name"
      t.integer "items_count", default: 0
      t.integer "position", default: 0
    end

    create_table "item_parents", force: true do |t|
      t.integer :item_id
      t.integer "parent_id"
      t.integer "position", default: 0
    end

    create_table "item_children", force: true do |t|
      t.integer :item_id
      t.integer "child_id"
      t.integer "position", default: 0
    end


  end
end
