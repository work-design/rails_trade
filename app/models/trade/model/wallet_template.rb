module Trade
  module Model::WalletTemplate
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string
      attribute :unit_name, :string
      attribute :rate, :string, comment: '相对于默认货币的比率'
      attribute :code, :string
      attribute :platform, :string
      attribute :enabled, :boolean, default: true
      attribute :hot, :boolean, default: false
      attribute :unit, :string
      attribute :digit, :integer, default: 0, comment: '精确到小数点后几位'
      attribute :limit, :decimal
      attribute :prepay_min, :decimal
      attribute :prepay_max, :decimal
      attribute :expire_min, :datetime
      attribute :expire_max, :datetime
      attribute :wallets_count, :integer, default: 0
      attribute :wallet_prepayments_count, :integer, default: 0

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :wallets, class_name: 'CustomWallet', dependent: :nullify
      has_many :advances, dependent: :destroy_async
      has_many :opened_advances, -> { includes(:card_template).opened.order(amount: :asc) }, class_name: 'Advance'
      has_many :unopened_advances, -> { includes(:card_template).unopened.order(amount: :asc) }, class_name: 'Advance'
      has_many :wallet_prepayments
      has_many :wallet_goods

      accepts_nested_attributes_for :advances

      has_one_attached :logo

      scope :hot, -> { where(hot: true) }

      validates :code, uniqueness: { scope: :organ_id }
    end

    def existing_good_types
      Trade::WalletGood.enum_base_i18n(:good_type).except(*wallet_goods.pluck(:good_type).uniq.map(&:to_sym)).invert
    end

    def set_prepay_range!
      self.prepay_min = wallet_prepayments.minimum(:amount)
      self.prepay_max = wallet_prepayments.maximum(:amount)
      self.save
    end

    def set_expire_range!
      self.expire_min = wallet_prepayments.minimum(:expire_at)
      self.expire_max = wallet_prepayments.maximum(:expire_max)
      self.save
    end

    def step
      (10 ** -digit).to_f
    end

    def wallet_price_goods(good_type)
      good_klass = good_type.safe_constantize
      if good_klass
        good_klass.where(organ_id: organ_id).json_filter_key(:wallet_price, code)
      end
    end

  end
end
