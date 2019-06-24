module RailsTrade::PromoteBuyer
  extend ActiveSupport::Concern
  included do
    attribute :state, :string, default: 'unused'
    attribute :status, :string, default: 'available'
    
    belongs_to :promote
    belongs_to :buyer, polymorphic: true, optional: true
    has_many :entity_promotes, dependent: :nullify
    
    enum state: {
      unused: 'unused',
      used: 'used',
      expired: 'expired'
    }
    enum status: {
      default: 'default',
      available: 'available',
      unavailable: 'unavailable'
    }

    scope :valid, -> { where(status: ['default', 'available']) }
  end

end
