class Promote < ApplicationRecord
  has_many :charges, primary_key: :code, foreign_key: :code

  validates :code, uniqueness: true

  enum scope: [
    :init,
    :wide
  ]

end

# :code, :string
# :start_at, :datetime
# :finish_at, :datetime