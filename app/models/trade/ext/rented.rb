module Trade
  module Ext::Rented
    extend ActiveSupport::Concern

    included do
      attribute :rents_count, :integer, default: 0
      attribute :rented, :boolean, default: false
      attribute :held, :boolean, comment: '是否被占有'

      belongs_to :held_user, class_name: 'Auth::User', optional: true
      belongs_to :held_member, class_name: 'Org::Member', optional: true
      belongs_to :held_organ, class_name: 'Org::Organ', optional: true

      has_many :rents, class_name: 'Trade::Rent', as: :rentable
      has_one :current_rent, ->(o) { where(user_id: o.held_user_id, member_organ_id: o.held_organ_id, rent_finish_at: nil) }, class_name: 'Trade::Rent', as: :rentable
      has_one :last_rent, -> { order(rent_start_at: :desc) }, class_name: 'Trade::Rent', as: :rentable

      scope :tradable, -> { where(held_user_id: nil, held_organ_id: nil) }
      scope :traded, -> { where.not(held_user_id: nil).or(where.not(held_organ_id: nil)) }
      scope :rented, -> { where(rented: true) }
      scope :held, -> { where(held: true) }

      after_save :increment_tradable_count, if: -> { !held && (saved_change_to_held?) }
      after_save :decrement_tradable_count, if: -> { held && saved_change_to_held? }

      after_destroy :decrement_tradable_count, if: -> { !held }
      after_destroy :increment_tradable_count, if: -> { held }
      after_save_commit :clear_held_later, if: -> { !held && saved_change_to_held? }
    end

    # 需在模型中定义并覆盖
    def good
    end

    def increment_tradable_count
    end

    def decrement_tradable_count
    end

    def clear_held_later
      RentClearJob.perform_later(self)
    end

    def clear_held
      self.held_user_id = nil
      self.held_member_id = nil
      self.held_organ_id = nil
      self.save
    end

    def do_rent(item)
      self.held_user_id = item.user_id
      self.held_member_id = item.member_id
      self.held_organ_id = item.member_organ_id
      self.rented = true if item.aim_rent?
      self.held = true
      #self.status = 'free' todo 考虑初始化状态
      self.rents.build(item_id: item.id)
      self

      save
    end

  end
end
