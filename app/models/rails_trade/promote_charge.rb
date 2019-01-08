class PromoteCharge < ApplicationRecord
  include ChargeModel

  # for record data
  attribute :subtotal, :decimal
  attribute :promote_buyer_id, :integer

  attribute :min, :integer
  attribute :max, :integer
  attribute :parameter, :decimal
  attribute :type, :string     # SingleCharge / TotalCharge

  belongs_to :item, class_name: 'Promote', inverse_of: :charges, foreign_key: :promote_id

  validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
  validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }

  # amount: 商品价格
  # return 计算后的价格
  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

end unless RailsTrade.config.disabled_models.include?('PromoteCharge')
