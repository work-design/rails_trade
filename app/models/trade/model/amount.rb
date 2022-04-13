module Trade
  module Model::Amount
    extend ActiveSupport::Concern

    included do
      attribute :item_amount, :decimal, default: 0
      attribute :overall_additional_amount, :decimal, default: 0
      attribute :overall_reduced_amount, :decimal, default: 0
      attribute :original_amount, :decimal, default: 0, comment: '原价，应用优惠之前的价格'
      attribute :amount, :decimal, default: 0
      attribute :lock_version, :integer
    end

    def xx
      trade.amount += changed_amount
    end

    def reset_amount
      self.compute_amount
      self.valid?
      self.changes
    end

    def reset_amount!(*args)
      self.reset_amount
      self.save(*args)
    end

  end
end
