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
      attribute :auto, :boolean, default: false, comment: '自动下单'
      attribute :myself, :boolean, default: true, comment: '自己下单，即 member.user.id == user_id'

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User'
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :payment_strategy, optional: true

      has_many :orders, dependent: :nullify
      has_many :promote_carts, dependent: :destroy_async
      has_many :available_promote_carts, -> { available }, class_name: 'PromoteCart'
      has_many :promotes, through: :promote_carts
      has_many :payment_references, dependent: :destroy_async
      has_many :payment_methods, through: :payment_references
      # https://github.com/rails/rails/blob/17843072b3cec8aee4e97d04ba4c4c6a5e83a526/activerecord/lib/active_record/autosave_association.rb#L21
      # 设置 autosave: false，当 trade_item 为 new_records 也不 save
      has_many :trade_items, ->(o) { default_where(organ_id: o.organ_id, member_id: o.member_id).carting }, inverse_of: :cart, foreign_key: :user_id, primary_key: :user_id, autosave: false
      has_many :checked_trade_items, ->(o) { default_where(organ_id: o.organ_id, member_id: o.member_id, status: 'checked') }, class_name: 'TradeItem', foreign_key: :user_id, primary_key: :user_id
      has_many :all_trade_items, ->(o) { default_where(organ_id: o.organ_id, member_id: o.member_id) }, class_name: 'TradeItem', foreign_key: :user_id, primary_key: :user_id
      has_many :trade_promotes, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id, trade_item_id: nil, order_id: nil) }, foreign_key: :user_id, primary_key: :user_id, autosave: true  # overall can be blank
      has_many :cards, -> { includes(:card_template) }, foreign_key: :user_id, primary_key: :user_id
      has_many :wallets
      has_one :wallet, -> { where(default: true) }, foreign_key: :user_id, primary_key: :user_id

      validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :member_id, uniqueness: { scope: [:organ_id, :user_id] }

      before_validation :sync_member_organ, if: -> { member_id_changed? && member }
      #before_validation :set_myself, if: -> { user_id_changed? || (member_id_changed? && member) }
      before_save :sync_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      before_save :compute_promote, if: -> { original_amount_changed? }
    end

    def name
      member&.name || user.name
    end

    def sync_member_organ
      self.member_organ_id = member.organ_id
      self.user_id ||= member.user&.id
    end

    def set_myself
      self.myself = (member.user&.id == user_id)
    end

    def sync_amount
      self.original_amount = item_amount + overall_additional_amount
    end

    def compute_amount
      self.retail_price = checked_trade_items.sum(&:retail_price)
      self.discount_price = checked_trade_items.sum(&:discount_price)
      self.bulk_price = self.retail_price - self.discount_price
      self.total_quantity = checked_trade_items.sum(&:original_quantity)
      sum_amount
    end

    def available_promotes
      overall_promotes = {}

      checked_trade_items.each do |i|
        overall_promotes.merge! i.available_promotes[1]
      end

      overall_promotes
    end

    def compute_promote(**extra)
      overall_promotes = available_promotes

      overall_promotes.each do |_, promote_hash|
        value = metering_attributes.fetch(promote_hash[:promote].metering, nil)
        next if value.nil?
        promote_charge = promote_hash[:promote].compute_charge(value, **extra)
        next unless promote_charge

        tp = trade_promotes.find(&->(i){ i.promote_good_id == promote_hash[:promote_good_id] }) || trade_promotes.build(promote_good_id: promote_hash[:promote_good_id])
        tp.promote_charge_id = promote_charge.id
        tp.compute_amount
      end
      trade_promotes.reject(&->(i){ overall_promotes.keys.include?(i.promote_id) }).each do |trade_promote|
        trade_promotes.destroy(trade_promote)
      end

      sum_amount
    end

    def sum_amount
      self.overall_additional_amount = trade_promotes.select(&->(o){ o.amount >= 0 }).sum(&:amount)
      self.overall_reduced_amount = trade_promotes.select(&->(o){ o.amount < 0 }).sum(&:amount)  # 促销价格
      self.item_amount = checked_trade_items.sum(&:amount)
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount
      self.changes
    end

    def get_trade_item(good_type:, good_id:, number: 1, produce_on: nil, scene_id: nil)
      trade_item = trade_items.find(&->(i){ i.good_type == good_type && i.good_id.to_s == good_id.to_s && i.produce_on.to_s == produce_on.to_s && i.scene_id.to_s == scene_id.to_s }) ||
        trade_items.build(good_id: good_id, good_type: good_type, produce_on: produce_on, scene_id: scene_id)

      if trade_item.persisted? && trade_item.checked?
        trade_item.number += (number.present? ? number.to_i : 1)
      elsif trade_item.persisted? && trade_item.init?
        trade_item.status = 'checked'
        trade_item.number = 1
      else
        trade_item.status = 'checked'
      end

      trade_item
    end

  end
end
