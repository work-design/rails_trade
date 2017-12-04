class GoodServe < ApplicationRecord
  belongs_to :good, polymorphic: true
  belongs_to :serve

  validates :serve_id, uniqueness: { scope: [:good_type, :good_id] }

end


# :good_type, :string
# :good_id, :integer
# :serve_id, :integer
