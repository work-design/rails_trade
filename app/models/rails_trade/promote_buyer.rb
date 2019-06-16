module RailsTrade::PromoteBuyer
  extend ActiveSupport::Concern
  included do
    attribute :state, :string, default: 'unused'
    
    belongs_to :promote
    belongs_to :buyer, polymorphic: true, optional: true

    validates :promote_id, uniqueness: { scope: [:buyer_type, :buyer_id] }

    enum state: {
      unused: 'unused',
      used: 'used',
      expired: 'expired'
    }
  end

end
