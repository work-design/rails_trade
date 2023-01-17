module Trade
  module Model::CardTemplate
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :description, :string
      attribute :text_color, :string
      attribute :cards_count, :integer, default: 0
      attribute :code, :string
      attribute :grade, :integer, default: 1, comment: '会员级别'

      belongs_to :organ, optional: true
      belongs_to :promote, optional: true
      belongs_to :parent, class_name: self.name

      has_one :purchase, -> { where(default: true) }
      has_many :cards, dependent: :nullify
      has_many :advances, dependent: :destroy_async
      has_many :purchases, dependent: :destroy_async
      has_many :privileges, dependent: :destroy_async
      has_many :opened_advances, -> { where(open: true).order(amount: :asc) }, class_name: 'Advance'
      has_many :unopened_advances, -> { where(open: false).order(amount: :asc) }, class_name: 'Advance'
      has_many :card_promotes, dependent: :destroy_async

      accepts_nested_attributes_for :advances

      has_one_attached :cover
      has_one_attached :logo

      scope :default, -> { where(parent_id: nil) }

      validates :code, uniqueness: { scope: :organ_id }
    end

  end
end
