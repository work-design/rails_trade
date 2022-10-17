module Trade
  module Model::ItemPromote
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal
      attribute :promote_name, :string
      attribute :value, :decimal

      belongs_to :item, inverse_of: :item_promotes, optional: true
      belongs_to :promote_good, counter_cache: true
      belongs_to :promote
      belongs_to :promote_charge, optional: true

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered'
      }, _default: 'init'

      validates :amount, presence: true

      before_validation :sync_promote, if: -> { promote_good_id_changed? && promote_good }
      before_validation :compute_amount, if: -> { value_changed? }
    end

    def sync_promote
      self.promote_id = self.promote_good.promote_id
    end

    def compute_amount
      self.promote_charge = promote.compute_charge(value, **item.extra)
      self.amount = self.promote_charge.final_price(value)
    end

  end
end
