module Trade
  module Model::ItemPromote
    extend ActiveSupport::Concern

    included do
      attribute :sequence, :integer
      attribute :amount, :decimal, default: 0, comment: ''
      attribute :promote_name, :string
      attribute :value, :decimal

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :cart
      belongs_to :cart_promote, ->(o){ where(cart_id: o.cart_id) }, foreign_key: :promote_id, primary_key: :promote_id, inverse_of: :item_promotes
      belongs_to :trade_item, inverse_of: :item_promotes, optional: true
      belongs_to :promote_good, counter_cache: true
      belongs_to :promote
      belongs_to :promote_charge

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered'
      }, _default: 'init'

      validates :amount, presence: true

      before_validation :sync_promote, if: -> { promote_good_id_changed? && promote_good }
      before_validation :sync_sequence, if: -> { promote_id_changed? && promote }
    end

    def sync_promote
      self.promote_id = self.promote_good.promote_id
    end

    def sync_sequence
      self.sequence = self.promote.sequence
    end

    def compute_amount
      self.value = trade_item.metering_attributes[promote.metering]
      self.promote_charge = promote.compute_charge(value, **trade_item.extra)
      self.based_amount = value + added_amount
      self.computed_amount = self.promote_charge.final_price(based_amount)
      self.amount = computed_amount unless edited?
      self
    end

  end
end
