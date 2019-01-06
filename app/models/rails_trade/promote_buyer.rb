class PromoteBuyer < ApplicationRecord
  belongs_to :promote
  belongs_to :buyer, polymorphic: true

  enum kind: {
    only: 'only',
    except: 'except'
  }, _prefix: true

  enum state: {
    unused: 'unused',
    used: 'used'
  }

  after_initialize if: :new_record? do
    if promote&.overall_buyers
      self.kind = 'except'
    else
      self.kind = 'only'
    end
  end

end unless RailsTrade.config.disabled_models.include?('PromoteBuyer')
