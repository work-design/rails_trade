module Trade
  class ItemCounterCache < ApplicationRecord
    include Statis::Ext::Config

    attribute :status, :string

    belongs_to :organ, class_name: 'Org::Organ', optional: true

    def sum_columns
      {
        amount: 'amount',
        ordered: ->(o) { o.where.not(order_id: nil) }
      }
    end

  end
end
