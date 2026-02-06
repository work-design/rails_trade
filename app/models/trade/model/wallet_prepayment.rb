module Trade
  module Model::WalletPrepayment
    extend ActiveSupport::Concern
    include Wechat::Ext::Handle if defined?(RailsWechat)

    included do
      attribute :token, :string
      attribute :amount, :decimal
      attribute :expire_at, :datetime
      attribute :used_at, :datetime
      attribute :lawful, :boolean, default: false

      belongs_to :wallet_template, optional: true

      has_one :wallet_advance

      scope :valid, -> { where(expire_at: Time.current..) }
      scope :unused, -> { where.missing(:wallet_advance).valid }

      validates :token, uniqueness: true

      before_validation :update_token, if: -> { new_record? }

      delegate :appid, to: :wallet_template
    end

    def update_token
      self.token = UidUtil.nsec_uuid 'WP'
      self
    end

    def qrcode_raw_url(port: 80)
      Rails.application.routes.url_for(
        controller: 'trade/my/wallet_templates',
        action: 'token_detect',
        token: token,
        port: port
      )
    end

    def qrcode_url
      QrcodeUtil.data_url(qrcode_raw_url)
    end

    def execute(user_id:, member_id: nil)
      wallet = wallet_template.wallets.find_or_initialize_by(user_id: user_id, member_id: member_id)

      wallet_advance || build_wallet_advance
      wallet_advance.wallet = wallet
      wallet_advance.amount = amount

      self.used_at = Time.current

      wallet.class.transaction do
        wallet.save!
        wallet_advance.save!
        self.save!
      end

      wallet
    end

  end
end

