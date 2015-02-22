class User < ActiveRecord::Base
  include TheAuthModel

  mount_uploader :avatar, AvatarUploader


  has_many :posts
  has_many :wikis
  has_many :photos
  has_many :orders
  has_many :user_signs, :dependent => :destroy
  has_many :signs, :through => :user_signs
  has_many :user_options
  has_many :contributions, :dependent => :destroy
  has_many :questions, :through => :contributions, :source => :contribute, :source_type => 'Question'
  has_many :options, :through => :contributions, :source => :contribute, :source_type => 'Option'




  # 是否是管理员
  def admin?
    Setting.admin_emails.include? self.email
  end

end
