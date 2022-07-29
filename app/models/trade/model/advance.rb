module Trade
  module Model::Advance
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal
      attribute :price, :decimal
      attribute :apple_product_id, :string, comment: 'For 苹果应用内支付'
      attribute :open, :boolean, default: false

      belongs_to :wallet_template
      belongs_to :card_template, optional: true

      has_many :wallet_advances

      scope :opened, -> { where(open: true) }
      scope :unopened, -> { where(open: false) }
      scope :without_card, -> { where(card_template_id: nil) }
      scope :with_card, -> { where.not(card_template_id: nil) }

      validates :amount, uniqueness: { scope: :card_template_id }
      validates :price, uniqueness: { scope: :card_template_id }

      has_one_attached :logo
      delegate :cover, :organ_id, to: :wallet_template

      before_validation :sync_name, if: -> { (changes.keys & ['wallet_template_id', 'amount']).present? }
    end

    def sync_name
      self.name = "#{wallet_template.name}-#{amount}"
    end

    def order_paid(trade_item)
      if trade_item.user_id
        wallet = wallet_template.wallets.find_or_initialize_by(user_id: trade_item.user_id, member_id: trade_item.member_id)
        wallet.maintain_id = trade_item.order.maintain_id if trade_item.order.respond_to?(:maintain_id)
      elsif trade_item.order.respond_to?(:maintain) && trade_item.order.maintain
        wallet = wallet_template.wallets.find_or_initialize_by(maintain_id: trade_item.order.maintain_id)
      else
        return
      end

      wa = wallet_advances.build
      wa.wallet = wallet
      wa.trade_item = trade_item
      wa.amount = amount

      wallet.class.transaction do
        wallet.save!
        wa.save!
      end

      wallet
    end

  end
end
