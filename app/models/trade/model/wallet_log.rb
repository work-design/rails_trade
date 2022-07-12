module Trade
  module Model::WalletLog
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :tag_str, :string
      attribute :amount, :decimal

      belongs_to :wallet
      belongs_to :source, polymorphic: true, optional: true

      validates :title, presence: true
    end

  end
end
