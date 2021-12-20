module Trade
  module Model::Privilege
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :amount, :integer, comment: '额度'
      attribute :price, :decimal, comment: '价格'
      attribute :code, :string

      belongs_to :card_template
      belongs_to :privileged, polymorphic: true

      has_one_attached :logo

      #validates :code, uniqueness: { scope: :card_template_id }
    end

  end
end
