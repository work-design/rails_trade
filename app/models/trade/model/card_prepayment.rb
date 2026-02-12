module Trade
  module Model::CardPrepayment
    extend ActiveSupport::Concern
    include Wechat::Ext::Handle if defined?(RailsWechat)
    include Inner::User

    included do
      attribute :token, :string, default: -> { UidUtil.nsec_uuid 'CP' }
      attribute :days, :integer, default: 0
      attribute :months, :integer, default: 0
      attribute :years, :integer, default: 0
      attribute :expire_at, :datetime
      attribute :used_at, :datetime
      attribute :activated, :boolean

      belongs_to :card_template, optional: true
      has_one :card_purchase

      scope :valid, -> { where(expire_at: Time.current..) }
      scope :unused, -> { where.missing(:wallet_advance).valid }
      scope :untaken, -> { where(user_id: nil) }

      validates :token, uniqueness: true

      before_validation :sync_from_template, if: :new_record?
    end

    def sync_from_template
      self.organ = card_template.organ
    end

    def qrcode_raw_url(port: 80)
      Rails.app.routes.url_for(
        controller: 'trade/my/card_templates',
        action: 'token_detect',
        token: token,
        port: port
      )
    end

    def qrcode_url
      QrcodeUtil.data_url(qrcode_raw_url)
    end

    def execute(user_id:, member_id: nil)
      card = card_template.cards.find_or_initialize_by(user_id: user_id, member_id: member_id)

      card_purchase || build_card_purchase
      card_purchase.card = card
      card_purchase.assign_attributes attributes.slice('years', 'months', 'days')

      self.used_at = Time.current

      card.class.transaction do
        card.save!
        card_purchase.save!
        self.save!
      end

      card
    end

  end
end

