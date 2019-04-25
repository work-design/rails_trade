module RailsTrade::ServeGood
  extend ActiveSupport::Concern
  included do
    attribute :serve_id, :integer
    attribute :good_id, :integer
    attribute :good_type, :string
  
    belongs_to :good, polymorphic: true
    belongs_to :serve
  end

end
