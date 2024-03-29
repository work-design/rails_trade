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
      attribute :enabled, :boolean, default: true
      attribute :unit, :string
      attribute :digit, :integer, default: 0, comment: '精确到小数点后几位'
      attribute :appid, :string, comment: '推广微信公众号'

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :wallets, class_name: 'CustomWallet', dependent: :nullify
      has_many :advances, dependent: :destroy_async
      has_many :opened_advances, -> { includes(:card_template).opened.order(amount: :asc) }, class_name: 'Advance'
      has_many :unopened_advances, -> { includes(:card_template).unopened.order(amount: :asc) }, class_name: 'Advance'
      has_many :wallet_prepayments
      has_many :wallet_goods

      has_one_attached :logo

      accepts_nested_attributes_for :advances

      validates :code, uniqueness: { scope: :organ_id }
    end

    def existing_good_types
      wallet_goods.where(good_id: nil).pluck(:good_type).uniq.map(&->(i){ Trade::PromoteGood.enum_i18n(:good_type, i) })
    end

    def step
      (10 ** -digit)
    end

  end
end
