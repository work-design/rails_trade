module Trade
  module Ext::Agency
    extend ActiveSupport::Concern

    included do
      has_many :cards, class_name: 'Trade::Card', dependent: :nullify
    end

  end
end
