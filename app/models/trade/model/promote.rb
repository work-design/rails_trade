module Trade
  module Model::Promote
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :short_name, :string
      attribute :code, :string
      attribute :unit_code, :string
      attribute :description, :string
      attribute :metering, :string
      attribute :editable, :boolean, default: false, comment: '是否可更改价格'
      attribute :verified, :boolean, default: false
      attribute :extra, :json

      belongs_to :organ, optional: true

      belongs_to :deal, polymorphic: true, optional: true
      belongs_to :unit, foreign_key: :unit_code, primary_key: :code, optional: true

      has_many :promote_charges, dependent: :delete_all
      has_many :promote_extras, dependent: :delete_all
      has_many :promote_goods, dependent: :destroy_async
      has_many :promote_good_types, dependent: :destroy_async
      has_many :promote_good_users, dependent: :destroy_async

      scope :verified, -> { where(verified: true) }
      scope :default, -> { verified.where(default: true) }
      scope :for_sale, -> { verified.where(default: false) }

      validates :code, uniqueness: true, allow_blank: true

      enum metering: {
        number: 'number', # 商品购买件数
        weight: 'weight', # 商品总重量, support sequence
        volume: 'volume', # 商品总体积, support sequence
        original_amount: 'original_amount', # 商品总金额, support sequence
        duration: 'duration'
      }
    end

    def extra_mappings
      promote_extras.pluck(:extra_name, :column_name).to_h
    end

    def existing_good_types
      promote_good_types.where(good_id: nil).pluck(:good_type).uniq.map(&->(i){ Trade::PromoteGood.enum_i18n(:good_type, i) })
    end

    def compute_charge(value, **extra)
      extra.transform_keys! { |key| extra_mappings[key.to_s] }
      extra.delete nil

      q_params = {
        'min-lte': value,
        'max-gte': value,
        **extra
      }

      promote_charges.default_where(q_params).take
    end

  end
end
