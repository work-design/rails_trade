module Trade
  module Model::ItemPromote
    extend ActiveSupport::Concern

    included do
      attribute :promote_name, :string
      attribute :value, :decimal
      attribute :amount, :decimal
      attribute :original_amount, :decimal
      attribute :unit_price, :decimal

      belongs_to :item, inverse_of: :item_promotes
      belongs_to :promote_good, counter_cache: true
      belongs_to :promote
      belongs_to :promote_charge

      enum :status, {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered'
      }, default: 'init'

      validates :amount, presence: true

      after_initialize :sync_promote, if: -> { new_record? && promote_good_id_changed? }
      after_initialize :compute_amount, if: -> { (['value', 'original_amount'] & changes.keys).present? }
    end

    def sync_promote
      self.promote = promote_good.promote
    end

    def compute_amount
      self.amount = self.promote_charge.final_price(original_amount, unit_price: unit_price)
    end

  end
end
