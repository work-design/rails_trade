module Trade
  module Inner::Charge
    extend ActiveSupport::Concern

    included do
      attribute :rent_start_at, :datetime
      attribute :rent_finish_at, :datetime
      attribute :rent_present_finish_at, :datetime
      attribute :rent_estimate_finish_at, :datetime
      attribute :estimate_metering, :json, default: {}
      attribute :estimate_amount, :json, default: {}

      attribute :start_at, :datetime, default: -> { Time.current }
      attribute :finish_at, :datetime
      attribute :estimate_finish_at, :datetime
      attribute :duration, :integer, default: 0

      has_one :rent_promote_good, ->(o) { rent.available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_one :rent_promote, -> { where(metering: 'duration') }, class_name: 'Trade::Promote', through: :rent_promote_good, source: :promote

      has_many :rent_promote_goods, ->(o) { rent.available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_many :rent_promotes, -> { where(metering: 'duration') }, class_name: 'Trade::Promote', through: :rent_promote_goods, source: :promote
      has_one :rent_promote_good, ->(o) { rent.available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_one :rent_promote, -> { where(metering: 'duration') }, class_name: 'Trade::Promote', through: :rent_promote_good, source: :promote

      before_save :compute_duration, if: -> { rent_finish_at.present? && rent_finish_at_changed? }
      before_save :compute_estimate_duration, if: -> { rent_estimate_finish_at.present? && rent_estimate_finish_at_changed? }

    end

    def compute_later(now = Time.current)
      return unless rent_promote
      if rent_present_finish_at
        r = rent_present_finish_at.parts.difference(rent_start_at.parts)

        if r.delete(TIME_UNIT[rent_promote.unit_code])
          next_at = rent_present_finish_at + 1.public_send(rent_promote.unit_code)
        else
          next_at = rent_present_finish_at.change(rent_start_at.parts.slice(*r.keys))
        end
      else
        next_at = rent_start_at + 1.public_send(rent_promote.unit_code)
      end

      if next_at <= now
        next_at += 1.public_send(rent_promote.unit_code)
      end

      ItemRentJob.set(wait_until: next_at).perform_later(self, next_at)
    end

    def compute_duration(now = rent_finish_at)
      self.duration = do_compute_duration(now)
    end

    def compute_present_duration!(next_at)
      self.rent_present_finish_at = next_at
      self.duration = do_compute_duration(rent_present_finish_at)
      self.save!
    end

    def compute_estimate_duration
      metering_hash = attributes.slice(*PROMOTE_COLUMNS)
      metering_hash.merge! 'duration' => do_compute_duration(rent_estimate_finish_at)  # 注意 hash key 须为 string 类型
      self.estimate_metering = metering_hash
      self.do_compute_promotes(estimate_metering)
      self.estimate_amount = self.sum_amount
    end

    def do_compute_duration(end_at = Time.current)
      return unless end_at && rent_promote
      r = end_at - rent_start_at
      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      x[rent_promote.unit_code].ceil
    end

  end
end

