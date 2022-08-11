module Trade
  module Model::Rent
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal, comment: '价格小计'
      attribute :rent_start_at, :datetime
      attribute :rent_finish_at, :datetime
      attribute :duration, :integer, default: 0

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :rentable, polymorphic: true, counter_cache: true, optional: true
      belongs_to :item

      before_validation :sync_from_item, if: -> { item_id_changed? && item }
      before_save :sync_duration, if: -> { rent_finish_at.present? && rent_finish_at_changed? }
      after_create_commit :compute_later
    end

    def sync_from_item
      self.user_id = item.user_id
      self.member_id = item.member_id
      self.member_organ_id = item.member_organ_id
      self.rent_start_at = item.rent_start_at
    end

    def sync_duration
      r = rent_finish_at - rent_start_at
      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      self.duration = x[promote.unit_code]
    end

    def promote
      item.good.available_promotes.find_by(metering: 'duration')
    end

    def compute_duration(now = nil)
      return duration if duration.present?

      if now.acts_like?(:time)
        r = now - rent_start_at
      elsif item.rent_estimate_finish_at.acts_like?(:time)
        r = item.rent_estimate_finish_at - rent_start_at
      else
        r = Time.current - rent_start_at
      end

      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      self.duration = x[promote.unit_code]
    end

  end
end
