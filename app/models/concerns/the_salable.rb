module TheSalable
  extend ActiveSupport::Concern

  included do
    belongs_to :good, primary_key: 'sku', foreign_key: 'sku', optional: true, autosave: true
    Good.belongs_to :entity, class_name: name, primary_key: 'sku', foreign_key: 'sku', autosave: true
  end

  def get_buyer

  end

end
