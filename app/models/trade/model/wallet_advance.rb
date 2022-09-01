module Trade
  module Model::WalletAdvance
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :amount, :decimal
      attribute :state, :string
      attribute :note, :string

      enum kind: {
        given: 'given'  # 系统赠送
      }

      belongs_to :operator, class_name: 'Org::Member', optional: true

      belongs_to :wallet
      belongs_to :advance, optional: true
      belongs_to :item, optional: true
      belongs_to :card_prepayment, optional: true

      has_one :wallet_log, ->(o){ where(wallet_id: o.wallet_id) }, as: :source

      enum state: {
        success: :success,
        failed: :failed
      }

      after_save :sync_to_wallet, if: -> { saved_change_to_amount? }
      after_destroy :sync_amount_after_destroy
      after_create_commit :sync_log
    end

    def sync_log
      log = self.wallet_log || self.build_wallet_log
      log.title = self.note.presence || I18n.t('wallet_log.income.wallet_advance.title')
      log.tag_str = I18n.t('wallet_log.income.wallet_advance.tag_str')
      log.amount = self.amount
      log.save
    end

    def sync_to_wallet
      wallet.income_amount += self.amount
      wallet.save
    end

    def sync_amount_after_destroy
      wallet.income_amount -= self.amount
      wallet.save
    end

  end
end
