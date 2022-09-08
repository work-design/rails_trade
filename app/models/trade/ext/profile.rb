module Trade
  module Ext::Profile
    extend ActiveSupport::Concern

    included do
      has_one :lawful_wallet, class_name: 'Trade::LawfulWallet'

      has_many :cards, class_name: 'Trade::Card'
    end

    def lawful_wallet
      super || create_lawful_wallet
    end

  end
end
