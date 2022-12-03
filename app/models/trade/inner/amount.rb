module Trade
  module Inner::Amount
    extend ActiveSupport::Concern

    included do
      attribute :item_amount, :decimal, default: 0
      attribute :overall_additional_amount, :decimal, default: 0
      attribute :overall_reduced_amount, :decimal, default: 0
      attribute :original_amount, :decimal, default: 0, comment: '原价，应用优惠之前的价格'
      attribute :amount, :decimal, default: 0
      attribute :lock_version, :integer
      attribute :extra, :json, default: {}

      after_validation :compute_amount, if: -> { new_record? || (changes.keys & ['item_amount', 'overall_additional_amount', 'overall_reduced_amount']).present? }
    end

    def compute_amount
      self.amount = item_amount + overall_additional_amount + overall_reduced_amount
    end

    def compute_promote
      available_item_promotes.group_by(&:promote).each do |promote, item_promotes|
        cp = cart_promotes.find(&->(i){ i.promote_id == promote.id }) || cart_promotes.build(promote_id: promote.id)
        cp.value = item_promotes.sum(&->(i){ i.value.to_d })
        cp.compute_amount
      end
      cart_promotes.select(&->(i){ available_item_promotes.map(&:promote_id).exclude?(i.promote_id) }).map(&:destroy)

      sequences = cart_promotes.map(&:sequence).uniq.sort!
      sequences.each do |sequence|
        x = cart_promotes.select(&->(i){ i.sequence == sequence })
        promotes = x.sort_by { |v| v.computed_amount }
        promotes[1..].each do |cart_promote|
          cart_promotes.destroy(cart_promote)
        end
      end
      self.overall_additional_amount = cart_promotes.select(&->(o){ o.amount >= 0 }).sum(&->(i){ i.amount.to_d })
      self.overall_reduced_amount = cart_promotes.select(&->(o){ o.amount < 0 }).sum(&->(i){ i.amount.to_d })
      self.changes
    end

    def reset_amount
      self.sum_amount
      self.valid?
      self.changes
    end

    def reset_amount!(*args)
      self.reset_amount
      self.save(*args)
    end

  end
end
