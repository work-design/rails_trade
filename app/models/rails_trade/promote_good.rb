module RailsTrade::PromoteGood
  extend ActiveSupport::Concern
  
  included do
    attribute :available, :boolean, default: false
    
    belongs_to :good, polymorphic: true, optional: true
    belongs_to :promote
    
    validates :promote_id, uniqueness: { scope: [:good_type, :good_id] }
  end
  
  

end
