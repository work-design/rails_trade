module Trade
  module Model::WalletGood
    extend ActiveSupport::Concern

    included do
      attribute :wallet_code, :string
      attribute :good_type, :string
      attribute :ratio, :decimal, precision: 3, scale: 2, default: 1

      belongs_to :wallet_template

      before_validation :sync_wallet_code, if: -> { wallet_template_id_changed? }
      after_save_commit :change_wallet_price, if: -> { saved_change_to_ratio? }
    end

    def sync_wallet_code
      self.wallet_code = wallet_template.code
    end

    def change_wallet_price
      Factory::Production.json_filter_any(:wallet_price, wallet_code).each do |good|
        good.set_wallet_price! self
      end
    end

  end
end
