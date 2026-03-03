module Trade
  module Model::WalletAdvance
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :amount, :decimal
      attribute :used_amount, :decimal, default: 0
      attribute :remaining_amount, :decimal
      attribute :note, :string
      attribute :expire_at, :datetime

      enum :kind, {
        given: 'given'  # 系统赠送
      }
      enum :state, {
        success: 'success',
        failed: 'failed'
      }

      belongs_to :wallet, optional: true
      belongs_to :advance, optional: true
      belongs_to :item, optional: true
      belongs_to :wallet_prepayment, optional: true

      has_many :wallet_logs

      before_save :compute_remaining_amount, if: -> { (changes.keys & ['amount', 'used_amount']).present? }
      after_save :sync_log, if: -> { saved_change_to_amount? }
      after_save :sync_to_wallet, if: -> { saved_change_to_amount? }
      after_destroy :sync_amount_after_destroy
      after_destroy :sync_destroy_log
    end

    def compute_remaining_amount
      self.remaining_amount = self.amount - self.used_amount
    end

    def sync_log
      log = self.wallet_logs.build
      log.title = self.note.presence || I18n.t('wallet_log.income.wallet_advance.title')
      log.tag_str = I18n.t('wallet_log.income.wallet_advance.tag_str')
      log.amount = self.amount - amount_before_last_save.to_d
      log.save
    end

    def sync_destroy_log
      log = self.wallet_logs.build
      log.title = self.note.presence || I18n.t('wallet_log.expense.wallet_advance.title')
      log.tag_str = I18n.t('wallet_log.expense.wallet_advance.tag_str')
      log.amount = -self.amount
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
