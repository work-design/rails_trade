module Trade
  class PaymentCounterCache < ApplicationRecord
    include Statis::Ext::Config

    attribute :state, :string
    attribute :pay_state, :string

    belongs_to :organ, class_name: 'Org::Organ', optional: true

    def sum_columns
      {
        total: 'total_amount',
        income: 'income_amount',
        orders: 'orders_amount'
      }
    end

  end
end
