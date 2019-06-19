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

    enum state: {
      init: 'init',
      checked: 'checked'
    }

    after_initialize if: :new_record? do
      self.promote_id = self.promote_charge.promote_id if self.promote
    end
    before_validation :compute_amount
  end

  def compute_charge
    self.amount = self.promote_charge.final_price cart_item.send(promote_charge.metering)
  end
  
end
