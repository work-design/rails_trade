class PromoteBuyer < ApplicationRecord
  belongs_to :promote
  belongs_to :buyer, polymorphic: true
  enum kind: {
    only: 'only',
    except: 'except'
  }

end unless RailsTrade.config.disabled_models.include?('PromoteBuyer')
