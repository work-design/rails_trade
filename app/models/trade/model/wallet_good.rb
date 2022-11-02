module Trade
  module Model::WalletGood
    extend ActiveSupport::Concern

    included do
      attribute :wallet_code, :string

      belongs_to :wallet_template
      belongs_to :good, polymorphic: true, optional: true

      before_validation :sync_wallet_code, if: -> { wallet_template_id_changed? }
    end

    def sync_wallet_code
      self.wallet_code = wallet_template.code
    end

  end
end
