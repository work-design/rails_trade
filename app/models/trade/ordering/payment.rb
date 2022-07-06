module Trade
  module Ordering::Payment
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal, default: 0
      attribute :received_amount, :decimal, default: 0
      attribute :payment_kind, :string

      before_save :check_state, if: -> { !pay_later && amount.zero? }
      after_save_commit :confirm_paid!, if: -> { all_paid? && saved_change_to_payment_status? }
      after_save_commit :confirm_part_paid!, if: -> { part_paid? && saved_change_to_payment_status? }
      after_save_commit :confirm_pay_later!, if: -> { pay_later? && saved_change_to_pay_later? }
    end

    def can_pay?
      ['unpaid', 'to_check', 'part_paid'].include?(self.payment_status) && ['init'].include?(self.state)
    end

    def unreceived_amount
      self.amount.to_d - self.received_amount.to_d
    end

    def init_received_amount
      self.payment_orders.confirmed.sum(:check_amount)
    end

    def pending_payments
      Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.cart&.payment_method_ids, state: ['init', 'part_checked'])
    end

    def exists_payments
      Payment.where.not(id: self.payment_orders.pluck(:payment_id)).exists?(payment_method_id: self.cart&.payment_method_ids, state: ['init', 'part_checked'])
    end

    def confirm_paid!
      self.expire_at = nil
      self.paid_at = Time.current
      self.trade_items.update(status: 'paid')
      self.save
      send_notice
    end

    def confirm_part_paid!
      self.expire_at = nil
      self.paid_at = Time.current
      self.trade_items.update(status: 'part_paid')
      self.save
    end

    def confirm_pay_later!
      self.trade_items.update(status: 'pay_later')
    end

    def change_to_paid!(type:, payment_uuid: nil, params: {})
      if payment_uuid.present?
        payment = self.payments.find_by(type: type, payment_uuid: payment_uuid)
        self.check_state! if payment
        payment
      else
        payment = self.payments.build(type: type, payment_uuid: payment_uuid)
        payment.organ_id = organ_id
        payment.assign_detail params

        payment_order = self.payment_orders.find(&:new_record?)
        payment_order.check_amount = payment.total_amount
        payment_order.state = 'confirmed'
        begin
          self.save
        rescue ActiveRecord::RecordInvalid => e
          payment.errors.add :base, 'can not save'
          logger.error "#{payment.errors.full_messages.join(', ')}"
          raise e
        end
        payment
      end
    end

    def send_notice
      broadcast_action_to self, action: :update, target: 'order_result', partial: 'trade/my/orders/success', locals: { model: self }
    end

    def payment_result(payment_kind)
      if self.payment_status == 'all_paid'
        return self
      end

      if self.amount == 0
        self.received_amount = self.amount
        self.check_state!
      end

      if payment_kind.present?
        begin
          self.send payment_kind.to_s + '_result'
        rescue NoMethodError
          self
        end
      end

      self
    end

    def check_state
      if self.received_amount.to_d >= self.amount
        self.payment_status = 'all_paid'
      elsif self.received_amount.to_d > 0 && self.received_amount.to_d < self.amount
        self.payment_status = 'part_paid'
      elsif self.received_amount.to_d <= 0
        self.payment_status = 'unpaid'
      end
    end

    def check_state!
      self.received_amount = init_received_amount
      self.check_state
      self.save!
    end

  end
end
