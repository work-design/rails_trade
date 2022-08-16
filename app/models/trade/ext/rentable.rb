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

      belongs_to :item, class_name: 'Trade::Item', optional: true

      has_many :rents, class_name: 'Trade::Rent', as: :rentable

      scope :ordered, -> { where.not(item_id: nil) }
      scope :orderable, -> { where(item_id: nil) }
      scope :rentable, -> { where(rentable: true) }
    end

  end
end
