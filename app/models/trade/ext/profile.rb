module Trade
  module Ext::Profile
    extend ActiveSupport::Concern

    included do
      has_many :cards, class_name: 'Trade::Card', as: :client
    end

  end
end
