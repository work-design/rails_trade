module RailsTrade::PromoteBuyer
  extend ActiveSupport::Concern
  included do
    attribute :state, :string, default: 'unused'
    attribute :status, :string, default: 'available'
    
    belongs_to :promote
    belongs_to :promote_good
    belongs_to :buyer, polymorphic: true
    has_many :trade_promotes, dependent: :nullify
    
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
    
    before_validation do
      self.promote = self.promote_good.promote
    end
  end

end
