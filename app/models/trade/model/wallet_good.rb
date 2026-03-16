module Trade
  module Model::WalletGood
    extend ActiveSupport::Concern

    included do
      attribute :wallet_code, :string
      attribute :good_type, :string
      attribute :ratio, :decimal, precision: 3, scale: 2, default: 1

      belongs_to :wallet_template

      before_validation :sync_wallet_code, if: -> { wallet_template_id_changed? }
    end

    def sync_wallet_code
      self.wallet_code = wallet_template.code
    end

  end
end
