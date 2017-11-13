class SinglePromote < Promote
  has_many :charges, dependent: :delete_all


end