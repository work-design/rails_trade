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
      (last_expire_at || Data.today).since(duration).end_of_day
    end

    def sync_from_card
      if card.expire_at && card.expire_at.to_date >= Date.today
        self.state = 'continue'
      elsif card.expire_at && card.expire_at < Date.today
        self.state = 'renew'
      else
        self.state = 'fresh'
      end
      self.last_expire_at = card.expire_at
      self.years = purchase.years
      self.months = purchase.months
      self.days = purchase.days
    end

    def sync_to_card!
      if ['fresh', 'renew'].include? self.state
        card.effect_at = Time.current
      end
      card.expire_at = expire_at if (card.expire_at && card.expire_at < expire_at) || card.expire_at.blank?
      card.save!
    end

    def prune_to_card!
      card.expire_at = self.last_expire_at
      if card.expire_at.to_date == card.effect_at.to_date && card.temporary
        card.destroy
      else
        card.save!
      end
    end

  end
end
