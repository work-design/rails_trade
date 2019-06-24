module RailsTrade::PricePromote
  
  def compute_charge
    all_ids = good.valid_promote_ids
    all_ids -= buyer_promotes.pluck(:promote_id)

    compute_charges_with_buyer(promote_buyer_ids)
    compute_charges_with_good(promote_good_ids)
  end

  def buyer_params
    {
      buyer_type: order.buyer_type,
      buyer_id: order.buyer_id
    }
  end
  
  def compute_promote_with_buyer(promote_buyer_ids: [])
    promote_buyers = PromoteBuyer.where(id: promote_buyer_ids)
    
    promote_buyers.each do |promote_buyer|
      [:quantity, :number, :amount].map do |m|
        value = send("#{prefix}#{m}")
    
        promote_charge = promote.compute_charge(value, m, extra: extra)
        self.entity_promotes.build(promote_charge_id: promote_charge.id, promote_buyer_id: promote_buyer.id)
      end
    end
  end
  
  def compute_charge_with_good(promote_good_ids, extra: {}, prefix: '')
    promote_goods = PromoteGood.find promote_good_ids
    promote_goods.map do |promote_good|
      [:quantity, :number, :amount].map do |m|
        value = send("#{prefix}#{m}")
        
        promote_charge = promote.compute_charge(value, m, extra: extra)
        self.entity_promotes.build(promote_charge_id: promote_charge.id, promote_good_id: promote_good.id)
      end
    end
  end
  
end
