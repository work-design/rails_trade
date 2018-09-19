class ServeCharge < ApplicationRecord
  attr_accessor :subtotal, :default_subtotal, :cart_item_serve
  belongs_to :item, class_name: 'Serve', foreign_key: :serve_id

  validates :max, numericality: { greater_than: -> (o) { o.min } }
  validates :min, numericality: { less_than: -> (o) { o.max } }

  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

  def extra
    self.attributes.slice(*item.extra)
  end

  def self.min_step
    0.1.to_d.power(ServeCharge.columns_hash['min'].scale)
  end

  def self.max_step
    0.1.to_d.power(ServeCharge.columns_hash['max'].scale)
  end

  def self.extra_columns
    ServeCharge.attribute_names - ['id', 'serve_id', 'min', 'max', 'price', 'base_price', 'type', 'created_at', 'updated_at']
  end

  def self.extra_options
    extra_columns.map { |extra_column| [ServeCharge.human_attribute_name(extra_column), extra_column] }.to_h
  end

end unless RailsTrade.config.disabled_models.include?('ServeCharge')

# :min, :integer
# :max, :integer
# :price, :decimal
# :type, :string     # SingleCharge / TotalCharge