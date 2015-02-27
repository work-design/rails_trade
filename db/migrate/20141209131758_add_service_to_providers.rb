class AddServiceToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :service_tel, :string
    add_column :providers, :service_qq, :string
  end
end
