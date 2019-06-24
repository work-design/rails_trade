module RailsTrade::PricePromote
  
  def compute_promote(promote_buyer_ids: [])
    all_ids = good.valid_promote_ids
    
    if promote_buyer_ids.present?
      buyer_promotes = order.buyer.promote_buyers.where(id: Array(promote_buyer_ids))
      buyer_promotes.each do |promote_buyer|
        self.entity_promotes.build(promote_buyer_id: promote_buyer.id, promote_id: promote_buyer.promote_id)
      end
      
      all_ids -= buyer_promotes.pluck(:promote_id)
    end
    
    all_ids
  end
  
  def xx()
    compute_charges(pids: all_ids)
  end
  
  def compute_charges(promote_id, extra: {}, prefix: '')
    promote = Promote.find promote_id
    
    [:quantity, :number, :amount].map do |m|
      value = send("#{prefix}#{m}")
      
      promote_charge = promote.compute_charge(value, m, extra: extra)
      self.entity_promotes.build(promote_charge_id: promote_charge.id, promote_good_id: promote_good_id)
    end.flatten
  end
  
end
