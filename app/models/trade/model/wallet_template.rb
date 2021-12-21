module Trade
  module Model::WalletTemplate
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string
      attribute :currency, :string, default: 'CNY'
      attribute :wallets_count, :integer, default: 0
      attribute :code, :string
      attribute :platform, :string

      belongs_to :organ, optional: true

      has_many :wallets, dependent: :nullify
      has_many :advances, dependent: :destroy_async
      has_many :opened_advances, -> { where(open: true).order(amount: :asc) }, class_name: 'Advance'
      has_many :unopened_advances, -> { where(open: false).order(amount: :asc) }, class_name: 'Advance'

      validates :code, uniqueness: { scope: :organ_id }
    end

  end
end
