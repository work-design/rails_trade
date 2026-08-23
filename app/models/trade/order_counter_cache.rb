module Trade
  class OrderCounterCache < ApplicationRecord
    include Statis::Ext::Config

    attribute :state, :string
    attribute :payment_status, :string
    attribute :agent_id, :uuid, index: true

    belongs_to :organ, class_name: 'Org::Organ', optional: true

    def sum_columns
      {
        amount: 'amount',
        unreceived: 'unreceived_amount',
        received: 'received_amount'
      }
    end

  end
end
