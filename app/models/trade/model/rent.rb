module Trade
  module Model::Rent
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal, comment: '价格小计'
      attribute :rent_start_at, :datetime, default: -> { Time.current }
      attribute :rent_estimate_finish_at, :datetime
      attribute :rent_finish_at, :datetime
      attribute :duration, :integer, default: 0

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :rentable, polymorphic: true, counter_cache: true, optional: true
      belongs_to :trade_item

      before_validation :sync_from_trade_item, if: -> { trade_item_id_changed? && trade_item }
      after_create_commit :compute_later
    end

    def sync_from_trade_item
      self.user_id = trade_item.user_id
      self.member_id = trade_item.member_id
      self.member_organ_id = trade_item.member_organ_id
    end

    def compute_duration(now = Time.current)
      if rent_finish_at.acts_like?(:time)
        r = rent_finish_at - rent_start_at
      elsif rent_estimate_finish_at.acts_like?(:time)
        r = rent_estimate_finish_at - rent_start_at
      else
        r = now - rent_start_at
      end

      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!

      self.duration = x[trade_item.promote.unit_code]
    end

    def renting?
      rent_estimate_finish_at.blank? && rent_finish_at.blank?
    end

  end
end
