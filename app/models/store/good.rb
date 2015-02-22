class Good < ActiveRecord::Base
  mount_uploader :logo, LogoUploader

  default_scope -> { where(:published => true) }
  paginates_per 9

  belongs_to :provider
  belongs_to :promote

  has_many :cart_products
  has_many :sales
  has_many :photos, :as => :imageable

  has_many :good_items, dependent: :destroy
  has_many :items, :through => :good_items
  has_many :lists, :through => :items

  has_many :good_produces, dependent: :destroy

  validates :provider_id, presence: true


  def same_provider
    self.class.where(:provider_id => self.provider_id)
  end

end
