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

    def order_deliverable(item)
      if item.user_id
        card = card_template.cards.find_or_initialize_by(user_id: item.user_id, member_id: item.member_id)
        card.maintain_id = item.order.maintain_id if item.order.respond_to?(:maintain_id)
      elsif item.order.respond_to?(:maintain) && item.order.maintain
        card = card_template.cards.find_or_initialize_by(maintain_id: item.order.maintain_id)
      else
        return
      end

      card.temporary = false
      cp = card.card_purchases.build
      cp.item = item
      cp.years = years
      cp.months = months
      cp.days = days
      cp.purchase = self
      cp.price = price

      card.class.transaction do
        card.save!
        cp.save!
      end

      card
    end

    def order_trial(item)
      card = card_template.cards.find_or_initialize_by(user_id: item.user_id, member_id: item.member_id)
      card.item = item
      card.temporary = true
      card.save
    end

    def order_prune(item)
      card = card_template.cards.temporary.find_or_initialize_by(user_id: item.user_id, member_id: item.member_id, item_id: item.id)
      card.destroy
    end

    def set_default
      self.class.where.not(id: self.id).where(card_template_id: self.card_template_id).update_all(default: false)
    end

  end
end
