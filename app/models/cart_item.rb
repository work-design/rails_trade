# class CartItem < ApplicationRecord
#   belongs_to :good, polymorphic: true
#
#   scope :valid, -> { default_where(status: 'unpaid') }
#
#
#   enum status: [
#     :unpaid,
#     :deleted,
#     :paid
#   ]
#
#
# end
