class ServeCharge < ApplicationRecord
  attr_accessor :subtotal, :default_subtotal, :good_serve
  belongs_to :item, class_name: 'Serve', foreign_key: :serve_id

  validates :max, numericality: { greater_than: -> (o) { o.min } }
  validates :min, numericality: { less_than: -> (o) { o.max } }

  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

  def extra
    self.attributes.except('id', 'serve_id', 'min', 'max', 'price', 'type', 'created_at', 'updated_at')
  end

  def self.extra_columns
    ServeCharge.attribute_names - ['id', 'serve_id', 'min', 'max', 'price', 'type', 'created_at', 'updated_at']
  end

  def self.extra_options
    extra_columns.map { |extra_column| [ServeCharge.human_attribute_name(extra_column), extra_column] }.to_h
  end

end

# :min, :integer
# :max, :integer
# :price, :decimal
# :type, :string     # SingleCharge / TotalCharge