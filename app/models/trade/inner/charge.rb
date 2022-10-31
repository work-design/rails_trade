module Trade
  module Inner::Charge
    extend ActiveSupport::Concern

    included do
      attribute :min, :decimal, precision: 10, scale: 2, default: 0
      attribute :max, :decimal, precision: 10, scale: 2, default: 99999999.99
      attribute :filter_min, :decimal, precision: 10, scale: 2, default: 0
      attribute :filter_max, :decimal, precision: 10, scale: 2, default: 99999999.99
      attribute :contain_min, :boolean, default: true
      attribute :contain_max, :boolean, default: false
      attribute :parameter, :decimal, precision: 10, scale: 2, default: 0
      attribute :base_price, :decimal, precision: 10, scale: 2, default: 0
      attribute :extra, :json

      scope :filter_with, ->(amount) { default_where('filter_min-lte': amount, 'filter_max-gte': amount) }

      validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
      validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }
      #validates :min, uniqueness: { scope: [:contain_min, :contain_max] }  # todo
      before_validation :compute_filter_value
    end

    # amount: 商品价格
    # return 计算后的价格
    def final_price(amount)
      base_price + (amount * parameter).round(2)
    end

    def compute_filter_value
      if contain_min
        self.filter_min = min
      else
        self.filter_min = min + self.min_step
      end
      if contain_max
        self.filter_max = max
      else
        self.filter_max = max - self.max_step
      end
    end

    def min_step
      0.1.to_d.power(self.class.columns_hash['min'].scale || self.class.columns_hash['min'].limit || 2)
    end

    def max_step
      0.1.to_d.power(self.class.columns_hash['max'].scale || self.class.columns_hash['max'].limit || 2)
    end

  end
end
