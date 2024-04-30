module Trade
  module Model::ItemPromote
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal
      attribute :promote_name, :string
      attribute :value, :decimal

      belongs_to :item, inverse_of: :item_promotes
      belongs_to :promote_good, counter_cache: true
      belongs_to :promote
      belongs_to :promote_charge

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered'
      }, _default: 'init'

      validates :amount, presence: true

      after_initialize :sync_promote, if: -> { new_record? && promote_good_id_changed? }
      after_initialize :compute_amount, if: -> { value_changed? }
    end

    def sync_promote
      self.promote = promote_good.promote
    end

    def compute_amount
      self.amount = self.promote_charge.final_price(value)
    end

  end
end
