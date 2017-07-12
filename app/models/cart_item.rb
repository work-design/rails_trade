# class CartItem < ApplicationRecord
#   belongs_to :good, polymorphic: true
#
#   # enum status: [
#   #   :unpaid,
#   #   :deleted,
#   #   :paid
#   # ]
#
#   scope :valid, -> { default_where(status: 0) }
#
#
# end
