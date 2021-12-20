module Trade
  module Model::Payment::CardPayment
    extend ActiveSupport::Concern

    included do
      belongs_to :wallet
      has_many :wallet_logs, ->(o){ where(wallet_id: o.wallet_id) }, as: :source

      before_validation :init_amount, if: -> { checked_amount_changed? }
      after_update :sync_amount, if: -> { saved_change_to_total_amount? }
      after_create_commit :sync_wallet_log, if: -> { saved_change_to_total_amount? }
      after_destroy :sync_amount_after_destroy
      after_destroy_commit :sync_destroy_wallet_log
    end

    def init_amount
      self.total_amount = checked_amount if total_amount.zero?
    end

    def assign_detail(params)
      self.notified_at = Time.current
      self.total_amount = params[:total_amount]
    end

    def compute_amount
      self.income_amount = 0
    end

    def sync_amount
      wallet.reload
      wallet.expense_amount += self.total_amount
      computed = wallet.compute_expense_amount
      if wallet.expense_amount == computed
        wallet.save!
      else
        wallet.errors.add :expense_amount, "#{wallet.expense_amount} Not Equal Computed #{computed}"
        logger.error "#{self.class.name}/Card: #{wallet.error_text}"
        raise ActiveRecord::RecordInvalid.new(wallet)
      end
    end

    def sync_amount_after_destroy
      wallet.reload
      wallet.expense_amount -= self.total_amount
      computed = wallet.compute_expense_amount
      if wallet.expense_amount == computed
        wallet.save!
      else
        wallet.errors.add :expense_amount, "#{wallet.expense_amount} Not Equal Computed #{computed}"
        logger.error "#{self.class.name}/Card: #{wallet.error_text}"
        raise ActiveRecord::RecordInvalid.new(wallet)
      end
    end

    def sync_wallet_log
      cl = self.wallet_logs.build
      cl.title = payment_uuid
      cl.tag_str = '支出'
      cl.amount = -self.total_amount
      cl.save
    end

    def sync_destroy_wallet_log
      cl = self.wallet_logs.build
      cl.title = payment_uuid
      cl.tag_str = '退款'
      cl.amount = self.total_amount
      cl.save
    end

  end
end
