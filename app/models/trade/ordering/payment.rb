module Trade
  module Ordering::Payment
    extend ActiveSupport::Concern

    def pending_payments
      Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.cart&.payment_method_ids, state: ['init', 'part_checked'])
    end

    def exists_payments
      Payment.where.not(id: self.payment_orders.pluck(:payment_id)).exists?(payment_method_id: self.cart&.payment_method_ids, state: ['init', 'part_checked'])
    end

    def change_to_paid!(payment_uuid: nil, params: {})
      if payment_uuid.present?
        payment = Payment.find_by(payment_uuid: payment_uuid)
        self.check_state! if payment
        payment
      else
        payment = Payment.build(payment_uuid: payment_uuid)
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


  end
end
