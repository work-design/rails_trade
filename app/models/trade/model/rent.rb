module Trade
  module Model::Rent
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal, comment: '价格小计'
      attribute :start_at, :datetime
      attribute :finish_at, :datetime
      attribute :estimate_finish_at, :datetime
      attribute :duration, :integer, default: 0
      attribute :invest_amount, :decimal, comment: '投资分成'

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :rentable, polymorphic: true, counter_cache: true, optional: true

      before_save :sync_duration, if: -> { (finish_at.present? || estimate_finish_at.present?) && (['finish_at', 'estimate_finish_at'] & changes.keys).present? }
      before_save :compute_amount, if: -> { duration_changed? && duration.to_i > 0 }
      before_save :compute_invest_amount, if: -> { amount_changed? }
      after_save :sync_rentable_state, if: -> { saved_change_to_finish_at? }
    end

    def sync_from_item
      self.user_id = item.user_id
      self.member_id = item.member_id
      self.member_organ_id = item.member_organ_id
      self.start_at = item.rent_start_at || Time.current
    end

    def sync_duration
      if finish_at
        r = finish_at - start_at
      else
        r = estimate_finish_at - start_at
      end
      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      self.duration = x[promote.unit_code].ceil if promote
    end

    def promote
      good.available_promotes.find_by(metering: 'duration')
    end

    def compute_amount
      results = promote.compute_price(duration, **extra)
      self.amount = results.sum
    end

    def compute_invest_amount
      self.invest_amount = self.amount * rentable.box_specification.invest_ratio
    end

    def sync_rentable_state
      rentable.rented = false
      rentable.held_user_id = nil
      rentable.save!
    end

  end
end
