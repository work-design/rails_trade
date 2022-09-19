module Trade
  module Ext::Rentable
    extend ActiveSupport::Concern

    included do
      attribute :rents_count, :integer, default: 0
      attribute :rented, :boolean, default: false

      belongs_to :held_user, class_name: 'Auth::User', optional: true
      belongs_to :held_member, class_name: 'Org::Member', optional: true
      belongs_to :held_organ, class_name: 'Org::Organ', optional: true

      has_many :rents, class_name: 'Trade::Rent', as: :rentable
      has_one :current_rent, ->(o){ where(user_id: o.held_user_id, member_organ_id: o.held_organ_id, finish_at: nil) }, class_name: 'Trade::Rent', as: :rentable
      has_one :last_rent, -> { order(start_at: :desc) }, class_name: 'Trade::Rent', as: :rentable

      scope :tradable, -> { where(held_user_id: nil, held_organ_id: nil) }
      scope :traded, -> { where.not(held_user_id: nil).or(where.not(held_organ_id: nil)) }
      scope :rented, -> { where(rented: true) }
    end

    # 需在模型中定义并覆盖
    def good
    end

    def do_rent(item)
      self.held_user_id = item.user_id
      self.held_organ_id = item.member_organ_id
      self.rented = true if item.aim_rent?
      #self.status = 'free' todo 考虑初始化状态
      self.rents.build(item_id: item.id)
      self

      save
    end

  end
end
