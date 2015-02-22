class Provider < ActiveRecord::Base
  mount_uploader :logo, LogoUploader

  belongs_to :area
  belongs_to :user
  has_many :products
  has_many :posts, :as => :wordage
  has_many :photos, :as => :imageable

end
