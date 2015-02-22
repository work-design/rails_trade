class GoodItem < ActiveRecord::Base
  mount_uploader :picture, PictureUploader

  belongs_to :item
  belongs_to :good
  belongs_to :list

  scope :the_list, ->(list_id){ where(list_id: list_id) }

  before_save :update_list_id

  def update_list_id
    self.list_id = self.item.list_id
  end

end
