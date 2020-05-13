module RailsTrade::TotalCart
  extend ActiveSupport::Concern

  included do
    attribute :retail_price, :decimal, default: 0, comment: '汇总：原价'
    attribute :discount_price, :decimal, default: 0, comment: '汇总：优惠'
    attribute :bulk_price, :decimal, default: 0, comment: ''
    attribute :total_quantity, :decimal, default: 0
    attribute :deposit_ratio, :integer, default: 100, comment: '最小预付比例'

    belongs_to :user
    has_many :carts, foreign_key: :user_id, primary_key: :user_id
    has_many :trade_items, foreign_key: :user_id, primary_key: :user_id
  end


end
