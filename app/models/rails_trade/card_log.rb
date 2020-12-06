module RailsVip::CardLog
  extend ActiveSupport::Concern

  included do
    attribute :title, :string
    attribute :tag_str, :string
    attribute :amount, :decimal, precision: 10, scale: 2, default: 1

    belongs_to :card
    belongs_to :source, polymorphic: true, optional: true

    default_scope -> { order(id: :desc) }
  end

end
