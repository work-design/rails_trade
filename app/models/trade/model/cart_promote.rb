module Trade
  module Model::CartPromote
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

      belongs_to :cart, inverse_of: :cart_promotes
      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :order, inverse_of: :cart_promotes, optional: true
      belongs_to :promote
      belongs_to :promote_charge

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered'
      }, _default: 'init'

      validates :amount, presence: true

      after_initialize if: :new_record? do
        self.sequence = self.promote.sequence if self.promote
      end
      after_update :sync_to_cart, if: -> { order.present? && saved_change_to_order_id? }
    end

    def compute_amount
      self.based_amount = cart.metering_attributes.fetch(promote.metering, 0)
      self.computed_amount = self.promote_charge.final_price(based_amount)
      self.amount = computed_amount unless edited?
      self
    end

    def sync_to_cart
      cart.trade_promotes.reload
      cart.reset_amount!
    end

  end
end
