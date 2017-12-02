class Sale < ApplicationRecord
  belongs_to :good
  belongs_to :suggest, :class_name => 'Product', :foreign_key => :add_id

end
