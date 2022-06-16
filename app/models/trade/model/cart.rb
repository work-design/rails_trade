module Trade
  module Model::Cart
    extend ActiveSupport::Concern

    included do
      attribute :good_type, :string
      attribute :aim, :string
      attribute :retail_price, :decimal, default: 0, comment: '汇总：原价'
      attribute :discount_price, :decimal, default: 0, comment: '汇总：优惠'
      attribute :bulk_price, :decimal, default: 0
      attribute :total_quantity, :decimal, default: 0
      attribute :deposit_ratio, :integer, default: 100, comment: '最小预付比例'
      attribute :auto, :boolean, default: false, comment: '自动下单'
      attribute :trade_items_count, :integer, default: 0

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :address, class_name: 'Profiled::Address', optional: true
      belongs_to :payment_strategy, optional: true

      has_many :orders, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id) }, foreign_key: :user_id, primary_key: :user_id
      has_many :promote_goods, foreign_key: :user_id, primary_key: :user_id
      has_many :available_promote_goods, -> { available }, class_name: 'PromoteGood'
      has_many :payment_references, dependent: :destroy_async
      has_many :payment_methods, through: :payment_references
      has_many :trade_items, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id, good_type: o.good_type, aim: o.aim).carting }, foreign_key: :user_id, primary_key: :user_id
      has_many :checked_trade_items, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id, aim: o.aim).checked }, class_name: 'TradeItem', foreign_key: :user_id, primary_key: :user_id
      has_many :all_trade_items, ->(o) { where(organ_id: o.organ_id, member_id: o.member_id, aim: o.aim) }, class_name: 'TradeItem', foreign_key: :user_id, primary_key: :user_id
      has_many :current_trade_items, class_name: 'TradeItem', foreign_key: :current_cart_id
      has_many :cart_promotes, inverse_of: :cart, autosave: true  # overall can be blank
      has_many :cards, -> { includes(:card_template) }, foreign_key: :user_id, primary_key: :user_id
      has_many :wallets, -> { includes(:wallet_template) }, foreign_key: :user_id, primary_key: :user_id
      has_one :wallet, -> { where(default: true) }, foreign_key: :user_id, primary_key: :user_id

      validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
      validates :member_id, uniqueness: { scope: [:organ_id, :user_id, :good_type, :aim] }

      before_validation :sync_member_organ, if: -> { member_id_changed? && member }
      before_save :sync_amount, if: -> { (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
      before_save :compute_promote, if: -> { original_amount_changed? }
    end

    def sync_member_organ
      self.member_organ_id = member.organ_id
      self.user ||= member.user
    end

    def sync_amount
      self.original_amount = item_amount + overall_additional_amount
    end

    def owned?(card_template)
      cards.where(card_template_id: card_template.id, temporary: false).take
    end

    def temp_owned?(card_template)
      cards.temporary.find_by(card_template_id: card_template.id)
    end

    def compute_amount
      self.retail_price = checked_trade_items.sum(&:retail_price)
      self.discount_price = checked_trade_items.sum(&:discount_price)
      self.bulk_price = self.retail_price - self.discount_price
      self.total_quantity = checked_trade_items.sum(&:original_quantity)
      sum_amount
    end

    def available_promotes
      promotes = {}

      checked_trade_items.each do |item|
        item.available_promotes.each do |promote_id, detail|
          promotes[promote_id] ||= []
          promotes[promote_id] << detail
        end
      end

      promotes.transform_keys!(&->(i){ Promote.find(i) })
    end

    def sum_amount
      self.overall_additional_amount = cart_promotes.select(&->(o){ o.amount >= 0 }).sum(&:amount)
      self.overall_reduced_amount = cart_promotes.select(&->(o){ o.amount < 0 }).sum(&:amount)  # 促销价格
      self.item_amount = checked_trade_items.sum(&:amount)
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount
      self.changes
    end

    def get_trade_item(good_type:, good_id:, aim: 'use', number: 1, **options)
      args = { good_type: good_type, good_id: good_id, aim: aim, **options.slice(:produce_on, :scene_id, :fetch_oneself) }
      args.reject!(&->(_, v){ v.blank? })
      trade_item = find_trade_item(**args) || trade_items.build(args)

      if trade_item.persisted? && trade_item.status_checked?
        trade_item.number += (number.present? ? number.to_i : 1)
      elsif trade_item.persisted? && trade_item.status_init?
        trade_item.status = 'checked'
        trade_item.number = 1
      else
        trade_item.status = 'checked'
      end

      trade_item
    end

    def find_trade_item(good_id:, **options)
      args = { good_type: good_type, good_id: good_id, aim: aim, **options.slice(:fetch_oneself, :good_type, :aim) }
      args.merge! 'produce_on' => options[:produce_on].to_date if options[:produce_on].present?
      args.merge! 'scene_id' => options[:scene_id].to_i if options[:scene_id].present?
      args.reject!(&->(_, v){ v.blank? })
      args.stringify_keys!

      trade_items.find(&->(i){ i.attributes.slice(*args.keys).reject(&->(_, v){ v.blank? }) == args })
    end

  end
end
