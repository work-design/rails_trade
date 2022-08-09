module Trade
  module Ordering::Rent
    extend ActiveSupport::Concern

    included do
      attribute :rent_start_at, :datetime, default: -> { Time.current }
      attribute :rent_estimate_finish_at, :datetime
      attribute :rent_finish_at, :datetime

      after_create_commit :compute_later, if: -> { aim_rent? }
    end

    def compute_duration(now = Time.current)
      if rent_finish_at.acts_like?(:time)
        r = rent_finish_at - rent_start_at
      elsif rent_estimate_finish_at.acts_like?(:time)
        r = rent_estimate_finish_at - rent_start_at
      else
        r = now - rent_start_at
      end

      ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
    end

    def renting?
      rent_estimate_finish_at.blank? && rent_finish_at.blank?
    end

    def promote
      good.available_promotes[0]
    end

    def compute_continue(now = Time.current)
      compute_later(now) if renting?
    end

    def compute_later(now = Time.current)
      wait = now.change(min: rent_start_at.min, sec: rent_start_at.sec)
      wait += 1.hour if wait <= now

      RentComputeJob.set(wait_until: wait).perform_later(self, wait)
    end

    def compute(now = Time.current)
      self.duration = compute_duration(now)[promote.unit_code]
      order.compute_promote
      order
    end

    def compute!(now = Time.current)
      compute(now)
      order.save
    end

  end
end
