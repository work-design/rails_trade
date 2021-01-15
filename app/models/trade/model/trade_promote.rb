module Trade
  module Model::TradePromote
    extend ActiveSupport::Concern

    included do
      attribute :sequence, :integer
      attribute :original_amount, :decimal, comment: '初始价格'
      attribute :based_amount, :decimal, default: 0, comment: '基于此价格计算，默认为 trade_item 的 amount，与sequence有关'
      attribute :computed_amount, :decimal, default: 0, comment: '计算出的价格'
      attribute :amount, :decimal, default: 0, comment: '默认等于 computed_amount，如果客服人员修改过价格后，则 amount 会发生变化'
      attribute :note, :string, comment: '备注'
      attribute :edited, :boolean, default: false, comment: '是否被客服改过价'
      attribute :promote_name, :string

      belongs_to :cart
      belongs_to :order, inverse_of: :trade_promotes
      belongs_to :trade_item, optional: true
      belongs_to :promote
      belongs_to :promote_charge
      belongs_to :promote_good
      belongs_to :promote_cart, counter_cache: true, optional: true

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered'
      }, _default: 'init'

      validates :promote_id, uniqueness: { scope: [:trade_type, :trade_id, :trade_item_id] }
      validates :amount, presence: true

      after_initialize if: :new_record? do
        if trade_item
          self.cart = trade_item.cart
          self.user_id = cart.user_id
          self.order = trade_item.order
        end
        if self.promote_good
          self.promote_id = self.promote_good.promote_id
        end
        self.sequence = self.promote.sequence
      end
      after_create_commit :check_promote_cart
    end

    def compute_amount
      if trade_item
        value = trade_item.metering_attributes.fetch(promote.metering, 0)
        added_amount = trade_item.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(&->(o){ o.send(promote.metering) })

        self.based_amount = value + added_amount
      else
        value = trade.metering_attributes.fetch(promote.metering, 0)
        added_amount = trade.trade_promotes.select { |cp| cp.promote.sequence < self.promote.sequence }.sum(&->(o){ o.send(promote.metering) })

        self.based_amount = value + added_amount
      end

      self.computed_amount = self.promote_charge.final_price(based_amount)
      self.amount = computed_amount unless edited?
      self
    end

    def check_promote_cart
      return unless promote_cart
      self.promote_cart.update state: 'used'
    end

  end
end
