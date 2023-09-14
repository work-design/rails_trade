# frozen_string_literal: true
module Trade
  module Ext::Purchase
    extend ActiveSupport::Concern

    included do
      has_many :purchase_items, class_name: 'Trade::Item', as: :purchase, foreign_type: :good_type
    end
  end
end
