class PromoteBuyer < ApplicationRecord
  belongs_to :promote
  belongs_to :buyer, polymorphic: true


end unless RailsTrade.config.disabled_models.include?('PromoteBuyer')
