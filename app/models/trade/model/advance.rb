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

      scope :open, -> { where(open: true) }

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
      if trade_item.respond_to?(:maintain) && trade_item.maintain
        wallet = wallet_template.wallets.find_or_initialize_by(client_type: trade_item.maintain.client_type, client_id: trade_item.maintain.client_id)
        wallet.agency_id = trade_item.maintain.agency_id
      else
        wallet = wallet_template.wallets.find_or_initialize_by(user_id: trade_item.user_id, member_id: trade_item.member_id)
      end
      wa = wallet.wallet_advances.build
      wa.trade_item = trade_item
      wa.amount = amount

      wallet.class.transaction do
        wallet.save!
        wa.save!
        trade_item.maintain.transfer! if trade_item.respond_to?(:maintain) && trade_item.maintain
      end

      wallet
    end

  end
end
