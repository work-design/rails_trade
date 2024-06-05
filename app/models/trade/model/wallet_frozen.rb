module Trade
  module Model::WalletFrozen
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal
      attribute :note, :string

      enum :state, {
        success: 'success',
        failed: 'failed'
      }

      belongs_to :operator, class_name: 'Org::Member', optional: true

      belongs_to :wallet
      belongs_to :item, optional: true

      has_one :wallet_log, ->(o) { where(wallet_id: o.wallet_id) }, as: :source

      after_create :sync_log
      after_save :sync_to_wallet, if: -> { saved_change_to_amount? }
      after_destroy :sync_amount_after_destroy
      after_destroy :sync_destroy_log
    end

    def sync_log
      log = self.build_wallet_log
      log.title = self.note.presence || I18n.t('wallet_log.income.wallet_frozen.title')
      log.tag_str = I18n.t('wallet_log.income.wallet_frozen.tag_str')
      log.amount = -self.amount
      log.save
    end

    def sync_destroy_log
      log = self.build_wallet_log
      log.title = self.note.presence || I18n.t('wallet_log.income.wallet_frozen.title')
      log.tag_str = I18n.t('wallet_log.income.wallet_frozen.tag_str')
      log.amount = self.amount
      log.save
    end

    def sync_to_wallet
      wallet.with_lock do
        wallet.frozen_amount = wallet.frozen_amount.to_d + self.amount
        wallet.save
      end
    end

    def sync_amount_after_destroy
      wallet.with_lock do
        wallet.frozen_amount = wallet.frozen_amount.to_d - self.amount
        wallet.save
      end
    end

  end
end
