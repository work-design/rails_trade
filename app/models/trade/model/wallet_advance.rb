module Trade
  module Model::WalletAdvance
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :amount, :decimal
      attribute :note, :string

      enum kind: {
        given: 'given'  # 系统赠送
      }
      enum state: {
        success: 'success',
        failed: 'failed'
      }

      belongs_to :operator, class_name: 'Org::Member', optional: true

      belongs_to :wallet
      belongs_to :advance, optional: true
      belongs_to :item, optional: true
      belongs_to :wallet_prepayment, optional: true

      has_one :wallet_log, ->(o){ where(wallet_id: o.wallet_id) }, as: :source, dependent: :destroy

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
      wallet.with_lock do
        wallet.advances_amount = wallet.advances_amount.to_d + self.amount
        wallet.save
      end
    end

    def sync_amount_after_destroy
      wallet.with_lock do
        wallet.advances_amount = wallet.advances_amount.to_d - self.amount
        wallet.save
      end
    end

  end
end
