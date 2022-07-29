module Trade
  module Model::WalletTemplate
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string
      attribute :unit_name, :string
      attribute :rate, :string, comment: '相对于默认货币的比率'
      attribute :wallets_count, :integer, default: 0
      attribute :code, :string
      attribute :platform, :string
      attribute :default, :boolean
      attribute :unit, :string

      enum unit_kind: {
        currency: 'currency',
        custom: 'custom'
      }

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :wallets, dependent: :nullify
      has_many :advances, dependent: :destroy_async
      has_many :opened_advances, -> { includes(:card_template).opened.order(amount: :asc) }, class_name: 'Advance'
      has_many :unopened_advances, -> { includes(:card_template).unopened.order(amount: :asc) }, class_name: 'Advance'
      has_many :wallet_prepayments

      has_one_attached :logo

      validates :code, uniqueness: { scope: :organ_id }

      scope :default, -> { where(default: true) }

      after_save :set_default, if: -> { default? && saved_change_to_default? }
    end

    def set_default
      self.class.where.not(id: self.id).where(organ_id: self.organ_id, default: true).update_all(default: false)
    end

    def set_wallets_default
      self.wallets.update(default: true)
    end

  end
end
