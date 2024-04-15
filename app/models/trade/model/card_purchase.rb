module Trade
  module Model::CardPurchase
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :days, :integer, default: 0
      attribute :months, :integer, default: 0
      attribute :years, :integer, default: 0
      attribute :note, :string
      attribute :last_expire_at, :datetime

      enum kind: {
        given: 'given'  # 系统赠送
      }
      enum state: {
        continue: 'continue',
        fresh: 'fresh',
        renew: 'renew'
      }

      belongs_to :card
      belongs_to :purchase
      belongs_to :item, optional: true

      has_one :card_log, ->(o){ where(card_id: o.card_id) }, as: :source

      before_create :sync_from_card
      after_save :sync_to_card!, if: -> { (saved_changes.keys & ['years', 'months', 'days', 'last_expire_at']).present? }
      after_destroy :prune_to_card!
    end

    def duration
      years.years + months.months + days.days
    end

    def expire_at
      if last_expire_at.blank?
        start_date = created_at.to_date
      else
        start_date = created_at > last_expire_at ? created_at : last_expire_at
      end

      start_date.since(duration).end_of_day
    end

    def sync_from_card
      if card.expire_at && card.expire_at.to_date >= created_at.to_date
        self.state = 'continue'
      elsif card.expire_at && card.expire_at < created_at
        self.state = 'renew'
      else
        self.state = 'fresh'
      end
      self.last_expire_at = card.expire_at || Time.current
      self.years = purchase.years
      self.months = purchase.months
      self.days = purchase.days
    end

    def sync_to_card!
      if ['fresh', 'renew'].include? self.state
        card.effect_at = created_at
      end
      card.expire_at = expire_at if (card.expire_at && card.expire_at < expire_at) || card.expire_at.blank?
      card.save!
    end

    def prune_to_card!
      card.expire_at = self.last_expire_at
      if card.expire_at&.to_date == card.effect_at.to_date && card.temporary
        card.destroy
      else
        card.save!
      end
    end

  end
end
