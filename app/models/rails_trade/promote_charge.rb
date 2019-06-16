module RailsTrade::PromoteCharge
  COLUMN_NAMES = [
    'id',
    'promote_id',
    'min',
    'max',
    'parameter',
    'base_price',
    'type',
    'created_at',
    'updated_at'
  ].freeze
  extend ActiveSupport::Concern
  
  included do
    attribute :type, :string
    attribute :min, :integer
    attribute :max, :integer
    attribute :contain_max, :boolean, default: false
    attribute :parameter, :decimal
    attribute :base_price, :decimal, default: 0
    
    belongs_to :promote
    
    scope :filter_with, ->(amount){ default_where('min-lte': amount, 'max-gte': amount) }

    validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
    validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }
  end
  # amount: 商品价格
  # return 计算后的价格
  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

  def extra
    self.attributes.slice(*item.extra)
  end

  class_methods do
    def min_step
      0.1.to_d.power(self.columns_hash['min'].scale)
    end

    def max_step
      0.1.to_d.power(self.columns_hash['max'].scale)
    end

    def extra_columns
      self.attribute_names - COLUMN_NAMES
    end

    def extra_options
      extra_columns.map { |extra_column| [self.human_attribute_name(extra_column), extra_column] }.to_h
    end
  end
  
end
