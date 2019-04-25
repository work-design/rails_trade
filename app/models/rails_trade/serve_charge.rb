module RailsTrade::ServeCharge
  extend ActiveSupport::Concern
  included do
    include ChargeModel
  
    attribute :min, :integer
    attribute :max, :integer
    attribute :price, :decimal
    attribute :type, :string     # SingleCharge / TotalCharge
    attribute :subtotal, :decimal
  
    attr_accessor :default_subtotal, :cart_item_serve
    belongs_to :item, class_name: 'Serve', foreign_key: :serve_id
  
    validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
    validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }
  end
  
  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

end
