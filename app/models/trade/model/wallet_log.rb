module Trade
  module Model::WalletLog
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :tag_str, :string
      attribute :amount, :decimal, precision: 10, scale: 2

      belongs_to :user
      belongs_to :cash
      belongs_to :source, polymorphic: true, optional: true

      validates :title, presence: true

      after_initialize if: :new_record? do
        if self.user_id
          self.cash = user.cash
        else
          self.user_id = cash.user_id
        end
      end
    end

  end
end
