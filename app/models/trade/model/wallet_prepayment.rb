module Trade
  module Model::WalletPrepayment
    extend ActiveSupport::Concern

    included do
      attribute :token, :string
      attribute :amount, :decimal
      attribute :expire_at, :datetime
      attribute :lawful, :boolean, default: false

      belongs_to :wallet_template, optional: true

      before_validation :update_token, if: -> { new_record? }
    end

    def update_token
      self.token = UidHelper.nsec_uuid 'WP'
      self
    end

    def qrcode_url
      url = Rails.application.routes.url_for(controller: 'trade/my/wallets', action: 'token', token: token)
      QrcodeHelper.data_url(url)
    end

    def to_scene!
      return unless wallet_template.appid
      scene = Wechat::Scene.find_or_initialize_by(appid: wallet_template.appid, aim: 'prepayment', match_value: "prepayment_#{id}")
      scene.aim = 'prepayment'
      scene.refresh if scene.expired?
      scene.save
      scene
    end

  end
end

