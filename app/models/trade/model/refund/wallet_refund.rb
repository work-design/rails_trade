module Trade
  module Model::Refund::WalletRefund
    extend ActiveSupport::Concern

    included do
      belongs_to :wallet
      has_one :wallet_log, ->(o){ where(wallet_id: o.wallet_id) }, as: :source

      before_validation :sync_wallet, if: -> { payment.wallet_id != wallet_id }
      after_save :sync_amount, if: -> { completed? && (state_before_last_save == 'init' || saved_change_to_total_amount?) }
      after_create_commit :sync_wallet_log
    end

    def do_refund(params = {})
      self.state = 'completed'
    end

    def sync_wallet
      self.wallet = payment.wallet
      self.total_amount = payment.total_amount
    end

    def sync_amount
      wallet.with_lock do
        wallet.expense_amount -= self.total_amount
        wallet.save!
      end
    end

    def sync_wallet_log
      cl = self.wallet_log || self.build_wallet_log
      cl.title = wallet.name
      cl.tag_str = '余额退款'
      cl.amount = self.total_amount
      cl.save
    end

  end
end
