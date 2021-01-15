module RailsTrade::PaymentOrder
  extend ActiveSupport::Concern

  included do
    attribute :check_amount, :decimal, default: 0

    enum state: {
      init: 'init',
      confirmed: 'confirmed'
    }, _default: 'init'

    belongs_to :order, inverse_of: :payment_orders
    belongs_to :payment, inverse_of: :payment_orders
    has_one :refund, ->(o){ where(order_id: o.order_id) }, foreign_key: :payment_id, primary_key: :payment_id

    #validate :valid_check_amount
    validates :order_id, uniqueness: { scope: :payment_id }

    after_save :checked_payment, if: -> { confirmed? && (saved_change_to_state? || saved_change_to_check_amount?) }
    after_save :unchecked_payment, if: -> { init? && (state_before_last_save == 'confirmed' || saved_change_to_check_amount?) }
    after_destroy_commit :unchecked_to_order
  end

  def valid_check_amount
    if the_payment_amount > payment.total_amount + payment.adjust_amount
      self.errors.add(:check_amount, 'Total checked amount greater than payment\'s amount')
    end

    if the_order_amount > order.amount + order.adjust_amount
      self.errors.add(:check_amount, 'Total checked amount greater than Order\'s amount')
    end
  end

  def checked_payment
    checked_to_payment
    checked_to_order
  end

  def checked_to_payment
    payment.checked_amount += self.check_amount
    if payment.checked_amount == payment.compute_checked_amount
      payment.check_state
      payment.save!
    else
      payment.errors.add :checked_amount, 'check not equal'
      logger.error "#{self.class.name}/Payment: #{payment.error_text}"
      raise ActiveRecord::RecordInvalid.new(payment)
    end
  end

  def checked_to_order
    order.received_amount += self.check_amount
    if order.received_amount == order.compute_received_amount
      order.check_state
      order.save!
    else
      order.errors.add :received_amount, 'check not equal'
      logger.error "#{self.class.name}/Order: #{order.error_text}"
      raise ActiveRecord::RecordInvalid.new(order)
    end
  end

  def unchecked_payment
    unchecked_to_payment
    unchecked_to_order
  end

  def unchecked_to_payment
    self.payment && payment.reload

    payment.checked_amount -= self.check_amount
    if payment.checked_amount == payment.compute_checked_amount
      payment.check_state
      payment.save!
    else
      payment.errors.add :checked_amount, 'uncheck not equal'
      logger.error "#{self.class.name}/Payment: #{payment.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid.new(payment)
    end
  end

  def unchecked_to_order
    self.order && order.reload

    order.received_amount -= self.check_amount
    if order.received_amount == order.compute_received_amount
      order.check_state
      order.save!
    else
      order.errors.add :received_amount, 'uncheck not equal'
      logger.error "#{self.class.name}/Order: #{order.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid.new(order)
    end
  end

  def confirm!
    self.state = 'confirmed'
    self.save!
  end

  def revert_confirm!
    self.state = 'init'
    self.save!
  end

end
