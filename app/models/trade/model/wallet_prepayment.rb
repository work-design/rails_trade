module Trade
  module Model::WalletPrepayment
    extend ActiveSupport::Concern

    included do
      attribute :token, :string
      attribute :amount, :decimal
      attribute :expire_at, :datetime

      belongs_to :wallet_template

      before_validation :update_token, if: -> { new_record? }
    end

    def update_token
      self.token = generate_token
      self
    end

    def qrcode_url
      url = Rails.application.routes.url_for(controller: 'trade/my/cards', action: 'token', token: token)
      QrcodeHelper.data_url(url)
    end

    def generate_token
      UidHelper.nsec_uuid 'CP'
    end

  end
end

