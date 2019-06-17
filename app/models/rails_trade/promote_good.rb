module RailsTrade::PromoteGood
  extend ActiveSupport::Concern
  
  included do
    attribute :promote_id, :integer
    attribute :good_id, :integer
    attribute :good_type, :string
    attribute :available, :boolean, default: false

    belongs_to :promote
    belongs_to :good, polymorphic: true, optional: true
    
    scope :available, -> { where(available: true) }
    scope :unavailable, -> { where(available: false) }
    
    validates :promote_id, uniqueness: { scope: [:good_type, :good_id] }
  end
  
  

end
