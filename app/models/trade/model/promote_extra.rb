module RailsTrade::PromoteExtra
  extend ActiveSupport::Concern
  included do
    attribute :extra_name, :string
    attribute :column_name, :string
    
    belongs_to :promote
    
    validates :extra_name, uniqueness: { scope: :promote_id }
  end
  
  
end
