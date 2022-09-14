module Trade
  module Model::Wallet::CustomWallet
    extend ActiveSupport::Concern

    included do
      before_validation :init_from_template, if: -> { wallet_template_id_changed? }
    end

    def init_from_template
      self.organ_id = wallet_template.organ_id
    end

  end
end
