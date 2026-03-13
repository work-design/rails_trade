module Trade
  class OrderCounterCache < ApplicationRecord
    include Statis::Ext::Config

    attribute :state, :string
    attribute :payment_status, :string

    belongs_to :organ, class_name: 'Org::Organ', optional: true

    def countable
      Order
    end

  end
end
