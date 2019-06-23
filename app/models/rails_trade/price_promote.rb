module RailsTrade::PricePromote

  def compute_charges(extra: {}, available_promote_ids: [], prefix: '', scope: ['overall', 'single'])
    extra.transform_values! { |v| [v, nil].flatten.uniq }
  
    [:quantity, :number, :amount].map do |m|
      value = send("#{prefix}#{m}")
      q_params = {
        promote_id: available_promote_ids,
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
