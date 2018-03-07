# should define methods: buyer & buyer_id
module TheTradeUser
  extend ActiveSupport::Concern

  included do
    attribute :buyer_id, :integer
    attribute :provider_id, :integer
  
    belongs_to :provider, inverse_of: :users, autosave: true, optional: true
    belongs_to :buyer, class_name: self.name

    has_many :addresses, foreign_key: :user_id, dependent: :nullify
    has_many :cart_items, foreign_key: :user_id, dependent: :nullify
    has_many :orders, foreign_key: :user_id, dependent: :nullify

    CartItem.belongs_to :user, class_name: self.name, optional: true
    Order.belongs_to :user, class_name: self.name, optional: true
    Address.belongs_to :user, class_name: self.name, optional: true
    PaymentReference.belongs_to :user, class_name: self.name, optional: true
  end

end

