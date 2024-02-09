module Trade
  module Model::Payment::WalletPayment
    extend ActiveSupport::Concern

    included do
      belongs_to :wallet
      has_many :wallet_logs, ->(o){ where(wallet_id: o.wallet_id) }, as: :source
      has_many :refunds, class_name: 'WalletRefund', primary_key: [:id, :wallet_id], query_constraints: [:payment_id, :wallet_id]

      validates :payment_uuid, presence: true, uniqueness: { scope: :type }

      before_validation :init_amount, if: -> { checked_amount_changed? }
      after_save :sync_amount, if: -> { saved_change_to_total_amount? }
      after_destroy :sync_amount_after_destroy
      after_create_commit :sync_wallet_log, if: -> { saved_change_to_total_amount? }
      after_destroy_commit :sync_destroy_wallet_log
    end

    def init_amount
      self.total_amount = checked_amount if total_amount.zero?
    end

    def desc
      if wallet.is_a?(LawfulWallet)
        type_i18n
      else
        wallet.wallet_template.name
      end
    end

    def assign_detail(params)
      self.notified_at = Time.current
      self.total_amount = params[:total_amount]
    end

    def compute_amount
      self.income_amount = 0
    end

    def sync_amount
      wallet.with_lock do
        wallet.payment_amount = wallet.payment_amount.to_d + self.total_amount
        wallet.save!
      end
    end

    def sync_amount_after_destroy
      wallet.with_lock do
        wallet.payment_amount = wallet.payment_amount.to_d - self.total_amount
        wallet.save!
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

    def card_pay
      if payment_status == 'all_paid'
        return { success: false, message: '已经支付过了，不要重复支付' }
      end

      self.class.transaction do
        params = {
          total_amount: self.unreceived_amount,
          adjust_amount: self.amount,
          user_id: self.user_id
        }

        payment = self.change_to_paid!(type: 'Trade::CardPayment', payment_uuid: UidHelper.nsec_uuid, params: params)
        { success: true, payment: payment }
      end
    rescue ActiveRecord::RecordInvalid => e
      return { success: false, message: e.message }
    end

  end
end
