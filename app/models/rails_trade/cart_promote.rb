module RailsTrade::CartPromote
  extend ActiveSupport::Concern
  included do
    attribute :cart_item_id, :integer
    attribute :serve_id, :integer
    attribute :good_type, :string
    attribute :good_id, :integer
    
    belongs_to :cart
    belongs_to :cart_item, touch: true, optional: true
    belongs_to :good, polymorphic: true
    belongs_to :promote_charge
    belongs_to :promote
    belongs_to :promote_buyer
    belongs_to :promote_good
    
    validates :promote_id, uniqueness: { scope: [:cart_item_id] }
    validates :amount, presence: true

    after_initialize if: :new_record? do |t|
      self.promote_id = self.promote_charge.promote_id if self.promote
    end

    enum state: {
      init: 'init',
      checked: 'checked'
    }
  end

  def get_charge
    charge = self.cart_item.serve.get_charge(serve)
    cart_item_serve = cart_item_serves.find { |cart_item_serve| cart_item_serve.serve_id == charge.serve_id  }
    if cart_item_serve.persisted?
      charge.cart_item_serve = cart_item_serve
      charge.subtotal = cart_item_serve.price
    end
    charge
  end
  
end
