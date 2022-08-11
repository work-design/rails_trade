module Trade
  module Ext::Sell
    extend ActiveSupport::Concern

    included do
      include Ext::Good

      belongs_to :user, class_name: 'Auth::User', optional: true

      has_one :item, as: :good, class_name: 'Trade::Item', dependent: :nullify
      has_one :order, through: :item
    end

    def update_order
      item.update amount: self.price
    end

    def get_order
      return @get_order if defined?(@get_order)
      @get_order = self.order || generate_order!(buyer: self.buyer, number: 1)
    end

  end
end
