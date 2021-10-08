# 数据定期清理
# 改变数据动作：
#   * 新增(check)
#   * 更新数量
#   * 选择或更换优惠券
#   * 选择服务
module Trade
  module Model::Cart
    extend ActiveSupport::Concern

    included do
      attribute :retail_price, :decimal, default: 0, comment: '汇总：原价'
      attribute :discount_price, :decimal, default: 0, comment: '汇总：优惠'
      attribute :bulk_price, :decimal, default: 0
      attribute :total_quantity, :decimal, default: 0
      attribute :deposit_ratio, :integer, default: 100, comment: '最小预付比例'
      attribute :current, :boolean, default: false

      belongs_to :user, class_name: 'Auth::User'
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :payment_strategy, optional: true

      has_many :orders, dependent: :nullify
      has_many :promote_carts, dependent: :destroy_async
      has_many :promotes, through: :promote_carts
      has_many :payment_references, dependent: :destroy_async
      has_many :payment_methods, through: :payment_references
      has_many :trade_items, -> { where(status: ['init', 'checked']) }, inverse_of: :cart, dependent: :destroy_async
      has_many :all_trade_items, class_name: 'TradeItem'
      has_many :trade_promotes, -> { where(trade_item_id: nil, order_id: nil) }, inverse_of: :cart, autosave: true, dependent: :destroy_async  # overall can be blank

      validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

      scope :current, -> { where(current: true) }

      before_save :sync_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      before_save :compute_promote, if: -> { original_amount_changed? }
      after_save :set_current, if: -> { current? && saved_change_to_current? }
    end

    def set_current
      self.class.where.not(id: self.id).where(current: true).update_all(current: false)
    end

    def sync_amount
      self.original_amount = item_amount + overall_additional_amount
    end

    def compute_amount
      self.retail_price = trade_items.select(&:checked?).sum(&:retail_price)
      self.discount_price = trade_items.select(&:checked?).sum(&:discount_price)
      self.bulk_price = self.retail_price - self.discount_price
      self.total_quantity = trade_items.select(&:checked?).sum(&:original_quantity)
      sum_amount
    end

    def available_promotes
      overall_promotes = {}

      trade_items.select(&:checked?).each do |i|
        overall_promotes.merge! i.available_promotes[1]
      end

      overall_promotes
    end

    def compute_promote(**extra)
      overall_promotes = available_promotes

      overall_promotes.each do |_, promote_hash|
        value = metering_attributes.fetch(promote_hash[:promote].metering)
        promote_charge = promote_hash[:promote].compute_charge(value, **extra)
        next unless promote_charge

        tp = trade_promotes.find(&->(i){ i.promote_good_id == promote_hash[:promote_good_id] && i.promote_cart_id == promote_hash[:promote_cart_id] }) || trade_promotes.build(promote_good_id: promote_hash[:promote_good_id], promote_cart_id: promote_hash[:promote_cart_id])
        tp.promote_charge_id = promote_charge.id
        tp.compute_amount
      end
      trade_promotes.reject(&->(i){ overall_promotes.keys.include?(i.promote_id) }).each do |trade_promote|
        trade_promote.destroy
      end

      sum_amount
    end

    def sum_amount
      self.overall_additional_amount = trade_promotes.select(&->(o){ o.amount >= 0 && (new_record? || persisted?) }).sum(&:amount)
      self.overall_reduced_amount = trade_promotes.select(&->(o){ o.amount < 0 && (new_record? || persisted?) }).sum(&:amount)  # 促销价格
      self.item_amount = trade_items.select(&:checked?).sum(&:amount)
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount
      self.changes
    end

    def valid_item_amount
      summed_amount = trade_items.select(&:checked?).sum(&:amount)

      unless self.item_amount == summed_amount
        errors.add :item_amount, "Item Amount: #{item_amount} not equal Summed amount: #{summed_amount}"
        logger.error "\e[35m  #{self.class.name}: #{error_text}  \e[0m"
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end

  end
end
