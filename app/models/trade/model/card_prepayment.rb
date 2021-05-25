module Trade
  module Model::CardPrepayment
    extend ActiveSupport::Concern

    included do
      attribute :token, :string
      attribute :amount, :decimal
      attribute :expire_at, :datetime

      belongs_to :card_template

      before_validation :update_token, if: -> { new_record? }
    end

    def update_token
      self.token = generate_token
      self
    end

    def generate_token
      UidHelper.nsec_uuid 'CP'
    end

  end
end

