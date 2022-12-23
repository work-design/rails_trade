module Trade
  module Model::Payout
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :payout_uuid, :string
      attribute :requested_amount, :decimal
      attribute :actual_amount, :decimal
      attribute :paid_at, :datetime
      attribute :advance, :boolean, default: false
      attribute :account_bank, :string
      attribute :account_name, :string
      attribute :account_num, :string

      enum state: {
        pending: 'pending',
        done: 'done',
        failed: 'failed'
      }, _default: 'pending'

      belongs_to :wallet
      belongs_to :operator, class_name: 'Auth::User', optional: true
      belongs_to :payable, polymorphic: true, optional: true

      has_one :wallet_log, ->(o) { where(wallet_id: o.wallet_id) }, as: :source

      has_one_attached :proof

      before_validation :init_uuid, if: -> { payout_uuid.blank? }
      #before_save :sync_state
      after_save :sync_to_wallet, if: -> { saved_change_to_requested_amount? }
      after_create_commit :sync_wallet_log
    end

    def init_uuid
      self.payout_uuid ||= UidHelper.nsec_uuid('POT')
    end

    def sync_state
      if requested_amount == actual_amount
        self.state = 'done'

        if advance
          payable.do_trigger(state: 'advance_paid')
        else
          payable.do_trigger(state: 'paid')
        end
      end
    end

    def sync_to_wallet
      (self.wallet && wallet.reload) || create_wallet

      wallet.expense_amount += self.requested_amount
      if wallet.expense_amount == wallet.compute_expense_amount
        wallet.save!
      else
        wallet.errors.add :expense_amount, 'not equal'
        raise ActiveRecord::RecordInvalid.new(wallet)
      end
    end

    def sync_wallet_log
      cl = self.wallet_log || self.build_wallet_log
      cl.title = '提现'
      cl.tag_str = '支出'
      cl.amount = -self.requested_amount
      cl.save
    end

  end
end
