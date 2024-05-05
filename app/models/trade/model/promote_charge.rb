module Trade
  module Model::PromoteCharge
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
      'unit_code',
      'created_at',
      'updated_at'
    ].freeze
    extend ActiveSupport::Concern
    include Inner::Charge

    included do
      attribute :type, :string

      belongs_to :promote
      has_many :minors, ->(o){ default_where(o.minor_filter_hash).order(min: :asc) }, class_name: self.name, primary_key: :promote_id, foreign_key: :promote_id

    end

    # amount: 商品价格
    # return 计算后的价格
    def final_price(amount = 1)
      raise 'Should Implement in Subclass'
    end

    def minor_filter_hash
      if contain_min
        { 'max-lt': min }
      else
        { 'max-lte': min }
      end
    end

    class_methods do
      def extra_columns
        self.column_names - COLUMN_NAMES
      end

      def extra_options
        extra_columns.map { |extra_column| [self.human_attribute_name(extra_column), extra_column] }.to_h
      end
    end

  end
end
