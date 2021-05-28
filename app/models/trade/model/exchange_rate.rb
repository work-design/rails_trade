module Trade
  module Model::ExchangeRate
    extend ActiveSupport::Concern

    included do
      attribute :from, :string
      attribute :to, :string
      attribute :rate, :decimal
    end

    class_methods do
      def get_rate(from_iso_code, to_iso_code)
        rate = find_by(from: from_iso_code, to: to_iso_code)
        rate&.rate
      end

      def add_rate(from_iso_code, to_iso_code, rate)
        exrate = find_or_initialize_by(from: from_iso_code, to: to_iso_code)
        exrate.rate = rate
        exrate.save!
      end

      def each_rate
        return find_each unless block_given?

        find_each do |rate|
          yield rate.from, rate.to, rate.rate
        end
      end

      def currency_options
        r = {}

        Money::Currency.table.each do |_, value|
          r.merge! value[:name] => value[:iso_code]
        end

        r
      end

    end

  end
end
