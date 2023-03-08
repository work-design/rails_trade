module Trade
  module Model::Purchase
    extend ActiveSupport::Concern

    included do
      attribute :price, :decimal
      attribute :title, :string
      attribute :note, :string
      attribute :years, :integer, default: 0
      attribute :months, :integer, default: 0
      attribute :days, :integer, default: 0
      attribute :default, :boolean, default: false

      belongs_to :card_template
      has_many :card_purchases

      delegate :cover, :organ_id, to: :card_template
      delegate :logo, to: :card_template

      after_update :set_default, if: -> { default? && saved_change_to_default? }
    end

    def duration
      years.years + months.months + days.days
    end

    def name
      "#{card_template.name}-#{price}"
    end

    def order_deliverable(item, temporary: false)
      card = card_template.cards.find_or_initialize_by(item.full_filter_hash)
      card.temporary = temporary

      cp = card.card_purchases.build(temporary: temporary)
      cp.item = item
      cp.purchase = self
      cp.price = price

      card.class.transaction do
        card.save!
        cp.save!
      end

      card
    end

    def order_prune(item)
      card = card_template.cards.temporary.find_by(item.full_filter_hash)
      cp = card.card_purchases.find_by(item_id: item.id)
      cp&.destroy
    end

    def set_default
      self.class.where.not(id: self.id).where(card_template_id: self.card_template_id).update_all(default: false)
    end

  end
end
