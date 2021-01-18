module Trade
  module Ext::Payable
    extend ActiveSupport::Concern

    included do
      has_many :payouts, as: :payable
    end

    def payout_amount
      self.amount.to_d
    end

    def to_advance_payout
      return unless payment_method
      payout = self.payouts.find_or_initialize_by(advance: true)
      payout.requested_amount = self.advance
      payout.payment_method_id = self.payment_method_id

      self.do_trigger state: 'advance_pay'
    end

    def advance_payout_id
      self.payouts.find_by(advance: true)&.id
    end

    def to_payout(type: 'WxpayPayout', account_num: nil)
      payout = self.payouts.find_or_initialize_by(type: type, advance: false)
      payout.requested_amount = self.payout_amount
      if self.cash
        payout.cash = cash
        payout.account_bank = cash.account_bank
        payout.account_name = cash.account_name
        payout.account_num = cash.account_num
      else
        payout.account_num = account_num
      end

      self.class.transaction do
        #self.do_trigger state: 'to_pay'
        payout.save!
      end
      payout
    end

    def payout_id
      self.payouts.find_by(advance: false)&.id
    end

  end
end
