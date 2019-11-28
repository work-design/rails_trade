module RailsTrade::PromoteCharge
  COLUMN_NAMES = [
    'id',
    'promote_id',
    'min',
    'max',
    'filter_min',
    'filter_max',
    'contain_min',
    'contain_max',
    'parameter',
    'base_price',
    'type',
    'metering',
    'unit',
    'created_at',
    'updated_at'
  ].freeze
  extend ActiveSupport::Concern
  
  included do
    attribute :type, :string
    attribute :unit, :string
    attribute :min, :decimal, precision: 10, scale: 2, default: 0
    attribute :max, :decimal, precision: 10, scale: 2, default: 99999999.99
    attribute :filter_min, :decimal, precision: 10, scale: 2, default: 0
    attribute :filter_max, :decimal, precision: 10, scale: 2, default: 99999999.99
    attribute :contain_min, :boolean, default: true
    attribute :contain_max, :boolean, default: false
    attribute :parameter, :decimal, precision: 10, scale: 2, default: 0
    attribute :base_price, :decimal, precision: 10, scale: 2, default: 0
    
    belongs_to :promote
    
    scope :filter_with, ->(amount){ default_where('filter_min-lte': amount, 'filter_max-gte': amount) }

    validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
    validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }
    #validates :min, uniqueness: { scope: [:contain_min, :contain_max] }  # todo
    before_validation :compute_filter_value
  end
  
  # amount: 商品价格
  # return 计算后的价格
  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end
  
  def compute_filter_value
    if contain_min
      self.filter_min = min
    else
      self.filter_min = min + self.class.min_step
    end
    if contain_max
      self.filter_max = max
    else
      self.filter_max = max - self.class.max_step
    end
  end

  def extra
    self.attributes.slice(*PromoteCharge.extra_columns)
  end

  class_methods do
    def min_step
      0.1.to_d.power(self.columns_hash['min'].scale)
    end

    def max_step
      0.1.to_d.power(self.columns_hash['max'].scale)
    end

    def extra_columns
      self.column_names - COLUMN_NAMES
    end

    def extra_options
      extra_columns.map { |extra_column| [self.human_attribute_name(extra_column), extra_column] }.to_h
    end
  end
  
end
