module RailsVip::Agency
  extend ActiveSupport::Concern

  included do
    has_many :cards, dependent: :nullify
  end
  

end
