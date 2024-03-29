module Trade
  module Model::Payment::HandPayment
    extend ActiveSupport::Concern

    included do
      has_many :refunds, class_name: 'HandRefund', foreign_key: :payment_id

      validates :payment_uuid, presence: true, uniqueness: { scope: :type }
    end

    def assign_detail(params)
      self.notified_at = Time.current
      self.assign_attributes params.slice(:total_amount, :payment_uuid)
    end

  end
end
