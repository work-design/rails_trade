module ChargeModel
  extend ActiveSupport::Concern

  included do
    def self.min_step
      0.1.to_d.power(self.columns_hash['min'].scale)
    end

    def self.max_step
      0.1.to_d.power(self.columns_hash['max'].scale)
    end

    def self.extra_columns
      self.attribute_names - [
        'id',
        'serve_id', 'promote_id',
        'min',
        'max',
        'parameter',
        'base_price',
        'type',
        'created_at',
        'updated_at',
        'subtotal'
      ]
    end

    def self.extra_options
      extra_columns.map { |extra_column| [self.human_attribute_name(extra_column), extra_column] }.to_h
    end
  end

  def extra
    self.attributes.slice(*item.extra)
  end

end
