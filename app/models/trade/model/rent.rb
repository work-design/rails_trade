module Trade
  module Model::Rent
    extend ActiveSupport::Concern

    included do
      attribute :amount, :decimal, comment: '价格小计'
      attribute :start_at, :datetime, default: -> { Time.current }
      attribute :finish_at, :datetime
      attribute :estimate_finish_at, :datetime
      attribute :duration, :integer, default: 0
      attribute :invest_amount, :decimal, comment: '投资分成'

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :rentable, polymorphic: true, counter_cache: true, optional: true
      belongs_to :good, polymorphic: true, optional: true

      has_many :rent_promote_goods, ->(o) { rent.available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_many :rent_promotes, -> { where(metering: 'duration') }, class_name: 'Trade::Promote', through: :rent_promote_goods, source: :promote
      has_one :rent_promote_good, ->(o) { rent.available.where(good_id: [o.id, nil]) }, class_name: 'Trade::PromoteGood', foreign_key: :good_type, primary_key: :good_type
      has_one :rent_promote, -> { where(metering: 'duration') }, class_name: 'Trade::Promote', through: :rent_promote_good, source: :promote

      before_validation :sync_from_rentable, if: -> { rentable_id_changed? && rentable_id.present? }
      before_save :sync_duration, if: -> { (finish_at.present? || estimate_finish_at.present?) && (['finish_at', 'estimate_finish_at'] & changes.keys).present? }
      before_save :compute_amount, if: -> { duration_changed? && duration.to_i > 0 }
      before_save :compute_invest_amount, if: -> { amount_changed? }
      after_save :sync_rentable_state, if: -> { saved_change_to_finish_at? }
    end

    def sync_from_rentable
      return unless rentable
      self.good = rentable.good
      self.user_id = rentable.held_user_id
      self.member_id = rentable.held_member_id
      self.member_organ_id = rentable.held_organ_id
    end

    def sync_duration
      if finish_at
        r = finish_at - start_at
      else
        r = estimate_finish_at - start_at
      end
      x = ActiveSupport::Duration.build(r.round).in_all.stringify_keys!
      self.duration = x[rent_promote.unit_code].ceil if rent_promote
    end

    def compute_amount
      return unless rent_promote
      results = rent_promote.compute_price(duration, **extra)
      self.amount = results.sum
    end

    def compute_invest_amount
      self.invest_amount = self.amount * rentable.box_specification.invest_ratio
    end

    def sync_rentable_state
      rentable.rented = nil
      rentable.held_user_id = nil
      rentable.held_member_id = nil
      rentable.held_organ_id = nil
      rentable.save!
    end

  end
end
