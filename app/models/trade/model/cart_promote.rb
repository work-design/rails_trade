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

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :cart, inverse_of: :cart_promotes, optional: true
      belongs_to :order, inverse_of: :cart_promotes, optional: true
      belongs_to :promote
      belongs_to :promote_charge

      has_many :item_promotes, dependent: :destroy_async

      enum status: {
        init: 'init',
        checked: 'checked',
        ordered: 'ordered'
      }, _default: 'init'

      validates :amount, presence: true

      after_initialize :init_sequence, if: -> { new_record? && self.promote }
      before_save :sync_amount, if: -> { computed_amount_changed? }
      after_update :sync_to_cart, if: -> { cart_id.present? && saved_change_to_cart_id? }
    end

    def init_sequence
      self.sequence = self.promote.sequence
    end

    def sync_amount
      self.amount = computed_amount unless edited?
    end

    def sync_to_cart
      return unless cart
      cart.cart_promotes.reload
      cart.reset_amount!
    end

  end
end
