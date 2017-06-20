module TheOrderable
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, optional: true
    has_many :payment_orders, dependent: :destroy
    has_many :payments, through: :payment_orders
  end

  def unreceived_amount
    self.amount - self.received_amount
  end

end
