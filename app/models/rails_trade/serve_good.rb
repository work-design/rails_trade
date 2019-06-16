module RailsTrade::ServeGood
  extend ActiveSupport::Concern
  included do
    attribute :serve_id, :integer
    attribute :good_id, :integer
    attribute :good_type, :string
    attribute :available, :boolean, default: false

    belongs_to :serve
    belongs_to :good, polymorphic: true, optional: true

    validates :serve_id, uniqueness: { scope: [:good_type, :good_id] }
  end

end
