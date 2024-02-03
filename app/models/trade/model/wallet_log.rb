module Trade
  module Model::WalletLog
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :tag_str, :string
      attribute :amount, :decimal

      belongs_to :wallet
      belongs_to :source, polymorphic: true, optional: true

      has_one :wallet_template, through: :wallet
    end

  end
end
