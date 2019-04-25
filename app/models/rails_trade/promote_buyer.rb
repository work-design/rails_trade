module RailsTrade::PromoteBuyer
  extend ActiveSupport::Concern
  included do
    attribute :state, :string, default: 'unused'
    belongs_to :promote
    belongs_to :buyer, polymorphic: true
  
    enum kind: {
      only: 'only',
      except: 'except'
    }, _prefix: true
  
    enum state: {
      unused: 'unused',
      used: 'used',
      expired: 'expired'
    }
  
    after_initialize if: :new_record? do
      if promote&.overall_buyers
        self.kind = 'except'
      else
        self.kind = 'only'
      end
    end
  end

end
