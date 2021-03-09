module Trade
  module Model::CardTemplate
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string
      attribute :valid_years, :integer, default: 0
      attribute :valid_months, :integer, default: 0
      attribute :valid_days, :integer, default: 0
      attribute :currency, :string

      belongs_to :organ, optional: true

      has_many :cards, dependent: :nullify
      has_many :advances, dependent: :destroy
      has_many :card_promotes, dependent: :destroy

      accepts_nested_attributes_for :advances

      has_one_attached :cover
    end

    def duration
      valid_years.years + valid_months.months + valid_days.days
    end

  end
end
