class Order < ActiveRecord::Base

  belongs_to :good
  belongs_to :user


end
