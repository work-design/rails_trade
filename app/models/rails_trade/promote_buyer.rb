class PromoteBuyer < ApplicationRecord
  belongs_to :promote
  belongs_to :buyer, polymorphic: true
  enum kind: {
    only: 'only',
    except: 'except'
  }, _prefix: true

end unless RailsTrade.config.disabled_models.include?('PromoteBuyer')
