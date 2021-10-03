module Trade
  module Model::PromoteGood
    extend ActiveSupport::Concern

    included do
      attribute :status, :string, default: 'available'
      attribute :effect_at, :datetime, default: -> { Time.current }
      attribute :expire_at, :datetime

      belongs_to :promote
      belongs_to :good, polymorphic: true, optional: true
      has_many :promote_carts, dependent: :delete_all

      scope :verified, -> { where(status: ['default', 'available']) }
      scope :valid, -> { t = Time.current; verified.default_where('effect_at-lte': t, 'expire_at-gte': t) }

      enum status: {
        default: 'default',  # 默认直接添加的服务，不可取消
        available: 'available',  # 可选
        unavailable: 'unavailable',  # 不可选
        specific: 'specific'  # 特定的？
      }

      validates :promote_id, uniqueness: { scope: [:good_type, :good_id] }
    end

    def promote_name
      promote.name
    end

  end
end
