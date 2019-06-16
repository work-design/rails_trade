module RailsTrade::ServeCharge
  extend ActiveSupport::Concern
  included do
    include RailsTrade::ChargeModel
  
    attribute :min, :integer
    attribute :max, :integer
    attribute :contain_max, :boolean, default: false
    attribute :parameter, :decimal
    attribute :type, :string
    attribute :subtotal, :decimal
  
    attr_accessor :default_subtotal, :cart_item_serve
    
    belongs_to :serve
    
    scope :filter_with, ->(amount){ default_where('min-lte': amount, 'max-gte': amount) }
  
    validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
    validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }
  end
  
  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

end
