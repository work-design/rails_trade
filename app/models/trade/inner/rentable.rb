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
      # 时间
      attribute :rent_start_at, :datetime
      attribute :rent_finish_at, :datetime, comment: '实际结束时间'
      attribute :rent_present_finish_at, :datetime, comment: '周期性计费时间'
      attribute :rent_estimate_finish_at, :datetime, comment: '预估结束时间'

      # 计时
      attribute :rent_duration, :integer
      attribute :rent_estimate_duration, :integer

      # 费用
      attribute :amount, :decimal
      attribute :wallet_amount, :json, default: {}
      attribute :estimate_amount, :decimal
      attribute :estimate_wallet_amount, :json, default: {}

      before_save :compute_duration, if: -> { rent_finish_at.present? && rent_finish_at_changed? }
      before_save :compute_estimate_duration, if: -> { rent_estimate_finish_at.present? && rent_estimate_finish_at_changed? }
      after_save_commit :compute_later, if: -> { aim_rent? && rent_start_at? && saved_change_to_rent_start_at? }
    end

    def unit_code
      good.rent_unit
    end

    def compute_charge(duration)
      good.rent_charges.default_where('min-lte': duration, 'max-gte': duration).take
    end

    def duration
      if rent_finish_at.present?
        result = rent_finish_at - rent_start_at
      elsif rent_present_finish_at
        result = rent_present_finish_at - rent_start_at
      else
        result = Time.current - rent_start_at
      end

      x = ActiveSupport::Duration.build(result.ceil).in_all.stringify_keys!
      self.rent_duration = x[unit_code]&.ceil
    end

    def estimate_duration
      result = rent_estimate_finish_at - rent_start_at

      x = ActiveSupport::Duration.build(result.ceil).in_all.stringify_keys!
      self.rent_estimate_duration = x[unit_code]&.ceil
    end

    def compute_later(now = Time.current)
      return unless unit_code
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
      _duration = duration
      rent_charge = compute_charge(_duration)

      self.amount = rent_charge.compute_price(_duration, **extra)
      self.original_amount = self.amount if respond_to?(:original_amount)
      self.single_price = self.amount if respond_to?(:single_price)
      good.wallet_codes.map do |wallet_code|
        self.wallet_amount.merge! wallet_code => rent_charge.compute_wallet_price(_duration, wallet_code)
      end
    end

    def compute_estimate_duration
      _estimate_duration = estimate_duration
      rent_charge = compute_charge(_estimate_duration)

      good.wallet_codes.map do |wallet_code|
        self.estimate_wallet_amount.merge! wallet_code => rent_charge.compute_wallet_price(_estimate_duration, wallet_code)
      end
      self.estimate_amount = rent_charge.compute_price(_estimate_duration, **extra)
    end

    def compute_present_duration!(next_at)
      self.rent_present_finish_at = next_at
      self.compute_duration
      self.save!
    end

  end
end

