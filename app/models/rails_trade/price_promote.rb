module RailsTrade::PricePromote
  
  def compute_promote(promote_buyer_ids: [])
    all_ids = good.available_promote_ids & Promote.default.pluck(:id)
    
    if promote_buyer_ids.present?
      buyer_promotes = order.buyer.promote_buyers.where(id: Array(promote_buyer_ids))
      buyer_promotes.each do |promote_buyer|
        self.order_promotes.build(promote_buyer_id: promote_buyer.id, promote_id: promote_buyer.promote_id)
      end
      
      all_ids -= buyer_promotes.pluck(:promote_id)
    end
    
    all_ids
  end
  
  def xx()
    compute_charges(pids: all_ids)
  end
  
  def compute_charges(extra: {}, pids: [], prefix: '', scope: ['overall', 'single'])
    extra.transform_values! { |v| [v, nil].flatten.uniq }
  
    [:quantity, :number, :amount].map do |m|
      value = send("#{prefix}#{m}")
      q_params = {
        promote_id: pids,
        'promote.scope': scope,
        metering: m.to_s,
        'min-lte': value,
        'max-gte': value,
        **extra
      }

      charges = PromoteCharge.default_where(q_params)
      charges = charges.reject do |charge|
        (charge.max == value && !charge.contain_max) || (charge.min == value && !charge.contain_min)
      end
      charges.each do |promote_charge|
        self.entity_promotes.build(promote_charge_id: promote_charge.id)
      end
    end.flatten
  end
  
end
