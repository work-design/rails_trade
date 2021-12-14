module Trade
  module Model::CardTemplate
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string
      attribute :currency, :string
      attribute :default, :boolean, default: false
      attribute :text_color, :string
      attribute :cards_count, :integer, default: 0

      belongs_to :organ, optional: true

      has_many :cards, dependent: :nullify
      has_many :advances, dependent: :destroy_async
      has_many :purchases, dependent: :destroy_async
      has_many :opened_advances, -> { where(open: true).order(amount: :asc) }, class_name: 'Advance'
      has_many :unopened_advances, -> { where(open: false).order(amount: :asc) }, class_name: 'Advance'
      has_many :card_promotes, dependent: :destroy_async
      has_many :card_prepayments, dependent: :delete_all

      accepts_nested_attributes_for :advances

      has_one_attached :cover
    end

  end
end
