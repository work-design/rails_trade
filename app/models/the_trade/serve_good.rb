class ServeGood < ApplicationRecord
  belongs_to :good, polymorphic: true
  belongs_to :serve

end

# :serve_id, :integer
# :good_id, :integer
# :good_type, :string
