module RailsTrade::Provided
  extend ActiveSupport::Concern
  include RailsTrade::PricePromote

  included do
    
    has_many :provider, optional: true
  end
  

 

  

end
