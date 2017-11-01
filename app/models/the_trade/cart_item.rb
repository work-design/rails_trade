class CartItem < ApplicationRecord
  belongs_to :good, polymorphic: true, optional: true
  scope :valid, -> { default_where(status: 'unpaid') }

  enum status: [
    :unpaid,
    :paid,
    :deleted
  ]

  after_initialize if: :new_record? do |t|
    self.status = 'unpaid'
  end

  def compute_fee
    _amount = good.price

    if good.unit
      promotes = Promote.where(unit: good.unit)
      promotes.each do |promote|
        _amount += promote.compute_price(good.quantity, good.unit)
      end
    end

    _amount
  end

  def single_subtotal
    self.compute_fee.to_d
  end

  def total_subtotal
    self.single_subtotal * self.quantity.to_i
  end


end
