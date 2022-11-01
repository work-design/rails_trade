module Trade
  module Inner::Rentable
    TIME_UNIT = {
      'seconds' => :sec,
      'minutes' => :min,
      'hours' => :hour,
      'days' => :day,
      'weeks' => :week,
      'months' => :month,
      'years' => :year
    }.freeze
    extend ActiveSupport::Concern

    included do
      attribute :rent_start_at, :datetime
      attribute :rent_finish_at, :datetime
      attribute :rent_present_finish_at, :datetime
      attribute :amount, :decimal
      attribute :rent_estimate_finish_at, :datetime
      attribute :estimate_amount, :json, default: {}

      before_save :compute_duration, if: -> { rent_finish_at.present? && rent_finish_at_changed? }
      before_save :compute_estimate_duration, if: -> { rent_estimate_finish_at.present? && rent_estimate_finish_at_changed? }
      after_save_commit :compute_later, if: -> { rent_start_at? && saved_change_to_rent_start_at? }
    end

    def unit_code
      good.rent_unit
    end

    def compute_charge(duration)
      good.rent_charges.default_where('min-lte': duration, 'max-gte': duration).take
    end

    def duration
      if rent_finish_at.present?
        rent_finish_at - rent_start_at
      elsif rent_present_finish_at
        rent_present_finish_at - rent_start_at
      else
        Time.current - rent_start_at
      end
    end

    def estimate_duration
      rent_estimate_finish_at - rent_start_at
    end

    def compute_later(now = Time.current)
      if rent_present_finish_at
        r = rent_present_finish_at.parts.difference(rent_start_at.parts)

        if r.delete(TIME_UNIT[unit_code])
          next_at = rent_present_finish_at + 1.public_send(unit_code)
        else
          next_at = rent_present_finish_at.change(rent_start_at.parts.slice(*r.keys))
        end
      else
        next_at = rent_start_at + 1.public_send(unit_code)
      end

      if next_at <= now
        next_at += 1.public_send(unit_code)
      end

      RentFreshJob.set(wait_until: next_at).perform_later(self, next_at)
    end

    def compute_duration
      x = ActiveSupport::Duration.build(duration).in_all.stringify_keys!
      rent_charge = compute_charge(duration)
      x[unit_code].ceil
      results = rent_charge.compute_price(x[unit_code].ceil, **extra)

      self.amount = results.sum
    end

    def compute_present_duration!(next_at)
      self.rent_present_finish_at = next_at
      self.compute_duration
      self.save!
    end

    def compute_estimate_duration
      x = ActiveSupport::Duration.build(estimate_duration.round).in_all.stringify_keys!
      rent_charge = compute_charge(self.estimate_duration)
      results = rent_charge.compute_price(x[unit_code].ceil, **extra)

      self.estimate_amount = results.sum
    end

  end
end

