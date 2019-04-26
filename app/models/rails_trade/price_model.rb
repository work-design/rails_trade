module RailsTrade::PriceModel
  extend ActiveSupport::Concern

  included do
    attribute :number, :integer, default: 1

    attribute :single_price, :decimal, default: 0  # 单价
    attribute :original_price, :decimal, default: 0  # 商品原价
    attribute :retail_price, :decimal, default: 0  # 单个商品零售价(商品原价 + 服务价)
    attribute :serve_price, :decimal, default: 0  # 附加服务价格汇总
    attribute :bulk_price, :decimal, default: 0  # 多个商品批发价
  end


end
