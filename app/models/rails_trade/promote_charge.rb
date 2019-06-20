module RailsTrade::PromoteCharge
  COLUMN_NAMES = [
    'id',
    'promote_id',
    'min',
    'max',
    'contain_min',
    'contain_max',
    'parameter',
    'base_price',
    'type',
    'metering',
    'created_at',
    'updated_at'
  ].freeze
  extend ActiveSupport::Concern
  
  included do
    attribute :type, :string
    attribute :min, :integer
    attribute :max, :integer
    attribute :contain_min, :boolean, default: true
    attribute :contain_max, :boolean, default: false
    attribute :parameter, :decimal
    attribute :base_price, :decimal, default: 0
    
    belongs_to :promote
    has_many :promote_extras, foreign_key: :promote_id, primary_key: :promote_id
    
    scope :filter_with, ->(amount){ default_where('min-lte': amount, 'max-gte': amount) }
    
    enum metering: {
      amount: 'amount',
      number: 'number',
      quantity: 'quantity'
    }

    validates :max, numericality: { greater_than_or_equal_to: -> (o) { o.min } }
    validates :min, numericality: { less_than_or_equal_to: -> (o) { o.max } }
  end
  
  # amount: 商品价格
  # return 计算后的价格
  def final_price(amount = 1)
    raise 'Should Implement in Subclass'
  end

  def extra
    self.attributes.slice(*promote.extra)
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
