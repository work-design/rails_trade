module RailsTrade::CartServe
  extend ActiveSupport::Concern
  included do
    attribute :cart_item_id, :integer
    attribute :serve_id, :integer
    attribute :good_type, :string
    attribute :good_id, :integer

    belongs_to :cart
    belongs_to :cart_item, touch: true, optional: true
    belongs_to :good, polymorphic: true
    belongs_to :serve_charge
    belongs_to :serve

    validates :serve_id, uniqueness: { scope: [:cart_item_id] }
    validates :amount, presence: true

    after_initialize if: :new_record? do |t|
      self.serve_id = self.serve_charge.serve_id if serve
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

end
