class OrderServe < ApplicationRecord
  attribute :order_id, :integer
  attribute :order_item_id, :integer

  belongs_to :order, inverse_of: :order_serves
  belongs_to :order_item, optional: true
  belongs_to :serve_charge, optional: true
  belongs_to :serve

  def compute_amount
    serve_charge, amount = self.serve.compute_amount(order_item.good, order_item.number, order_item.extra)

    self.amount = amount
    self.serve_charge_id = serve_charge.id
  end

end unless RailsTrade.config.disabled_models.include?('OrderServe')
