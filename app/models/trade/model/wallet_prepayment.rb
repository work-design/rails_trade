module Trade
  module Model::WalletPrepayment
    extend ActiveSupport::Concern
    include Wechat::Ext::Handle if defined?(RailsWechat)

    included do
      attribute :token, :string
      attribute :amount, :decimal
      attribute :expire_at, :datetime
      attribute :lawful, :boolean, default: false

      belongs_to :wallet_template, optional: true

      has_one :wallet_advance

      before_validation :update_token, if: -> { new_record? }

      delegate :appid, to: :wallet_template
    end

    def update_token
      self.token = UidHelper.nsec_uuid 'WP'
      self
    end

    def qrcode_url
      url = Rails.application.routes.url_for(controller: 'trade/my/wallet_templates', action: 'token', token: token)
      QrcodeHelper.data_url(url)
    end

    def execute(user_id:, member_id: nil)
      wallet = wallet_template.wallets.find_or_initialize_by(user_id: user_id, member_id: member_id)

      wallet_advance || build_wallet_advance
      wallet_advance.wallet = wallet
      wallet_advance.amount = amount

      wallet.class.transaction do
        wallet.save!
        wallet_advance.save!
      end

      wallet
    end

  end
end

