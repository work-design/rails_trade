module Trade
  module Model::WalletLog
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :tag_str, :string
      attribute :amount, :decimal

      belongs_to :operator, class_name: 'Org::Member', optional: true

      belongs_to :wallet, optional: true
      belongs_to :wallet_advance
      belongs_to :wallet_payment, optional: true
      belongs_to :source, polymorphic: true, optional: true

      has_one :wallet_template, through: :wallet
    end

  end
end
