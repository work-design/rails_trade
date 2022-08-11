module Trade
  module Model::ItemPromote
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal, default: 0, comment: ''
      attribute :promote_name, :string
      attribute :value, :decimal

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :cart, optional: true
      belongs_to :order, optional: true
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

      after_initialize :compute_amount, if: -> { new_record? && trade_item.present? }
      before_validation :sync_promote, if: -> { promote_good_id_changed? && promote_good }
    end

    def sync_promote
      self.promote_id = self.promote_good.promote_id
    end

    def compute_amount
      self.value = trade_item.metering_attributes[promote.metering]
      self.promote_charge = promote.compute_charge(value, **trade_item.extra)
      self.amount = self.promote_charge.final_price(value)
    end

  end
end
