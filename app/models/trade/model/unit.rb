module Trade
  module Model::Unit
    extend ActiveSupport::Concern

    included do
      attribute :default, :boolean
      attribute :rate, :decimal, comment: '相对于默认单位的计算比率'
      attribute :name, :string
      attribute :code, :string

      enum metering: {
        weight: 'weight',
        volume: 'volume',
        duration: 'duration'
      }

      after_update :set_default, if: -> { default? && saved_change_to_default? }
    end

    def set_default
      self.class.where.not(id: self.id).where(metering: self.metering).update_all(default: false)
    end

  end
end
