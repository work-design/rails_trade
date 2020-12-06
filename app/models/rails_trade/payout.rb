module RailsVip::Payout
  extend ActiveSupport::Concern

  included do
    attribute :type, :string
    attribute :payout_uuid, :string
    attribute :requested_amount, :decimal, precision: 10, scale: 2
    attribute :actual_amount, :decimal, precision: 10, scale: 2
    attribute :state, :string, default: 'pending'
    attribute :paid_at, :datetime
    attribute :advance, :boolean, default: false
    attribute :account_bank, :string
    attribute :account_name, :string
    attribute :account_num, :string
  
    belongs_to :cash
    belongs_to :operator, class_name: 'User', optional: true
    belongs_to :payable, polymorphic: true, optional: true
    
    has_one :cash_log, ->(o) { where(cash_id: o.cash_id) }, as: :source

    has_one_attached :proof
  
    enum state: {
      pending: 'pending',
      done: 'done',
      failed: 'failed'
    }
  
    before_validation do
      self.payout_uuid ||= UidHelper.nsec_uuid('POT')
    end
    #before_save :sync_state
    after_save :sync_to_cash, if: -> { saved_change_to_requested_amount? }
    after_create_commit :sync_cash_log
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

  def sync_to_cash
    (self.cash && cash.reload) || create_cash

    cash.expense_amount += self.requested_amount
    if cash.expense_amount == cash.compute_expense_amount
      cash.save!
    else
      cash.errors.add :expense_amount, 'not equal'
      raise ActiveRecord::RecordInvalid.new(cash)
    end
  end

  def sync_cash_log
    cl = self.cash_log || self.build_cash_log
    cl.title = '提现'
    cl.tag_str = '支出'
    cl.amount = -self.requested_amount
    cl.save
  end

end
