module Trade
  module Ext::Rentable
    extend ActiveSupport::Concern

    included do
      attribute :rents_count, :integer, default: 0
      attribute :rented, :boolean, default: false
      attribute :rentable, :boolean, default: true

      belongs_to :held_user, class_name: 'Auth::User', optional: true
      belongs_to :held_organ, class_name: 'Org::Organ', optional: true
      belongs_to :owned_user, class_name: 'Auth::User', optional: true
      belongs_to :owned_organ, class_name: 'Org::Organ', optional: true

      has_many :rents, class_name: 'Trade::Rent', as: :rentable
      has_one :current_rent, ->(o){ where(user_id: o.held_user_id, member_organ_id: o.held_organ_id, finish_at: nil) }, class_name: 'Trade::Rent', as: :rentable
      has_one :last_rent, -> { order(start_at: :desc) }, class_name: 'Trade::Rent', as: :rentable

      scope :ordered, -> { where.not(item_id: nil) }
      scope :orderable, -> { where(item_id: nil) }
      scope :rentable, -> { where(rentable: true) }
      scope :rented, -> { where(rented: true) }
    end

  end
end
