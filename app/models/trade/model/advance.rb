module Trade
  module Model::Advance
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal
      attribute :price, :decimal
      attribute :apple_product_id, :string, comment: 'For 苹果应用内支付'
      attribute :open, :boolean, default: false
      attribute :lawful, :boolean, default: false, comment: '是否法币'

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :wallet_template, optional: true
      belongs_to :card_template, optional: true

      has_many :wallet_advances

      scope :opened, -> { where(open: true) }
      scope :unopened, -> { where(open: false) }
      scope :without_card, -> { where(card_template_id: nil) }
      scope :with_card, -> { where.not(card_template_id: nil) }

      validates :amount, uniqueness: { scope: [:organ_id, :wallet_template_id, :open] }
      validates :price, uniqueness: { scope: [:organ_id, :wallet_template_id, :open] }

      has_one_attached :logo
      delegate :logo, to: :wallet_template, allow_nil: true

      before_validation :sync_name, if: -> { (changes.keys & ['wallet_template_id', 'amount']).present? }
    end

    def sync_name
      if wallet_template.present?
        self.name = "#{wallet_template.name}-#{amount}"
      else
        self.name = "#{amount}"
      end
    end

    def order_deliverable(item)
      if item.user_id
        if wallet_template
          wallet = wallet_template.wallets.find_or_initialize_by(user_id: item.user_id, member_id: item.member_id)
        else
          wallet = item.user.lawful_wallets.find_by(organ_id: organ_id) || item.user.lawful_wallets.create(organ_id: organ_id)
        end
        wallet.maintain_id = item.order.maintain_id if item.order.respond_to?(:maintain_id)
      elsif item.order.respond_to?(:maintain) && item.order.maintain
        wallet = wallet_template.wallets.find_or_initialize_by(maintain_id: item.order.maintain_id)
      else
        return
      end

      wa = wallet_advances.build
      wa.wallet = wallet
      wa.item = item
      wa.amount = amount

      wallet.class.transaction do
        wallet.save!
        wa.save!
      end

      wallet
    end

  end
end
