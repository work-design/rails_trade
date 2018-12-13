module ChargeModel

  def extra
    self.attributes.slice(*item.extra)
  end

  def self.min_step
    0.1.to_d.power(self.class.columns_hash['min'].scale)
  end

  def self.max_step
    0.1.to_d.power(self.class.columns_hash['max'].scale)
  end

  def self.extra_columns
    self.class.attribute_names - [
      'id',
      'serve_id',
      'min',
      'max',
      'price',
      'base_price',
      'type',
      'created_at',
      'updated_at'
    ]
  end

  def self.extra_options
    extra_columns.map { |extra_column| [self.class.human_attribute_name(extra_column), extra_column] }.to_h
  end

end
