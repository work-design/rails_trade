class Sale < ActiveRecord::Base

  belongs_to :product
  belongs_to :suggest, :class_name => 'Product', :foreign_key => :add_id

end
