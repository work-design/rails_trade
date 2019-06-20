module RailsTrade::PromoteExtra
  extend ActiveSupport::Concern
  included do
    belongs_to :extra
  end


end
