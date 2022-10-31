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
      attribute :duration, :integer, default: 0, comment: '单位统一为：秒'
      attribute :amount, :decimal
      attribute :rent_estimate_finish_at, :datetime
      attribute :estimate_duration, :json, default: {}
      attribute :estimate_amount, :json, default: {}

      before_save :compute_duration, if: -> { rent_finish_at.present? && rent_finish_at_changed? }
      before_save :compute_estimate_duration, if: -> { rent_estimate_finish_at.present? && rent_estimate_finish_at_changed? }
      after_save_commit :compute_later, if: -> { rent_start_at? && saved_change_to_rent_start_at? }
    end

    def unit_code

    end

    def rent_charge

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

    def compute_duration(now = rent_finish_at)
      self.duration = do_compute_duration(now)
      results = rent_charge.compute_price(estimate_duration, **extra)
      self.amount = results.sum
    end

    def compute_present_duration!(next_at)
      self.rent_present_finish_at = next_at
      self.duration = do_compute_duration(rent_present_finish_at)
      self.save!
    end

    def compute_estimate_duration
      self.estimate_duration = do_compute_duration(rent_estimate_finish_at)
      results = rent_charge.compute_price(estimate_duration, **extra)
      self.estimate_amount = results.sum
    end

    def do_compute_duration(end_at = Time.current)
      return unless end_at
      r = end_at - rent_start_at
      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      x[unit_code].ceil
    end

  end
end

