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
      attribute :extra, :json, default: {}
    end

    def xx
      trade.amount += changed_amount
    end

    def compute_promote
      promotes = available_promotes

      cart_promotes.where(status: 'init').where.not(promote_id: promotes.keys).delete_all
      promotes.map do |promote, available_items|
        value = available_items.sum(&->(i){ i[:trade_item].metering_attributes[promote.metering] })
        logger.debug("#{promote.metering} is #{value}")
        next if value.nil?
        promote_charge = promote.compute_charge(value, **extra)
        logger.debug("charge is #{promote_charge}")
        next unless promote_charge
      end
    end

    def compute_promote_amount
      result = compute_promote
      result.each do |promote, items|
        cp = cart_promotes.find(&->(i){ i.promote_id == promote.id }) || cart_promotes.build(promote_id: promote.id)
        available_items.each do |item|
          ip = cp.item_promotes.find_or_initialize_by(trade_item_id: item[:trade_item].id)
          ip.promote_good = item[:promote_good]
        end
        cp.based_amount = value
        cp.promote_charge = promote_charge
        cp.computed_amount = promote_charge.final_price(based_amount)
      end
      self.sum_amount
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
