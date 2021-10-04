module Trade
  module Model::Member
    extend ActiveSupport::Concern

    included do
      has_many :payment_references, dependent: :destroy_async, autosave: true
      has_many :payment_methods, through: :payment_references, autosave: true

      scope :credited, -> { where(payment_strategy_id: self.credit_ids) }
    end

    def last_overdue_date
      orders.order(overdue_date: :asc).first&.overdue_date
    end

    class_methods do

      def credit_ids
        PaymentStrategy.where.not(period: 0).pluck(:id)
      end

    end

  end
end
