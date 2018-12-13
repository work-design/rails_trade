class PromoteCharge < ApplicationRecord
  include ChargeModel
  attribute :subtotal, :decimal
  belongs_to :item, class_name: 'Promote', foreign_key: :promote_id

  validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
  validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }

  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

end unless RailsTrade.config.disabled_models.include?('PromoteCharge')

# :min, :integer
# :max, :integer
# :price, :decimal
# :type, :string     # SingleCharge / TotalCharge
