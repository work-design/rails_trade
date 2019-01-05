class PromoteBuyer < ApplicationRecord
  belongs_to :promote
  belongs_to :buyer, polymorphic: true
  enum kind: {
    include: 'include',
    exclude: 'exclude'
  }

end unless RailsTrade.config.disabled_models.include?('PromoteBuyer')
