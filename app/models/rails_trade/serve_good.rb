class ServeGood < ApplicationRecord
  attribute :serve_id, :integer
  attribute :good_id, :integer
  attribute :good_type, :string

  belongs_to :good, polymorphic: true
  belongs_to :serve

end unless RailsTrade.config.disabled_models.include?('ServeGood')
