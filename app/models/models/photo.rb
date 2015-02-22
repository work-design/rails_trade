class Photo < ActiveRecord::Base
  mount_uploader :photo, PhotoUploader
  acts_as_list :scope => :imageable
  belongs_to :user
  belongs_to :imageable, :polymorphic => true

  default_scope { order("position ASC") }



end
