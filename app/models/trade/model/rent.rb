module Trade
  module Model::Rent
    extend ActiveSupport::Concern
    include Inner::Rentable

    included do
      attribute :amount, :decimal, comment: '价格小计'

      attribute :invest_amount, :decimal, comment: '投资分成'
      attribute :extra, :json, default: {}

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      belongs_to :rentable, polymorphic: true, counter_cache: true, optional: true
      belongs_to :good, polymorphic: true, optional: true

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

    def compute_invest_amount
      self.invest_amount = self.amount * rentable.box_host.invest_ratio
    end

    def sync_rentable_state
      rentable.rented = nil
      rentable.held = false
      rentable.save!
    end

  end
end
