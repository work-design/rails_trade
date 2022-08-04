module Trade
  module Model::Payment::HandPayment
    extend ActiveSupport::Concern

    included do
      has_many :refunds, class_name: 'HandRefund'
    end

    def assign_detail(params)
      self.notified_at = Time.current
      self.total_amount = params[:total_amount]
    end

  end
end
