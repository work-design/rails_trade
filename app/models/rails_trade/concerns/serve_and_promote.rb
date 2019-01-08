module ServeAndPromote
  extend ActiveSupport::Concern

  included do
    attribute :promote_buyer_ids, :integer, array: true
    composed_of :serve,
                class_name: 'ServeFee',
                mapping: [
                  ['good_type', 'good_type'],
                  ['good_id', 'good_id'],
                  ['number', 'number'],
                  ['buyer_type', 'buyer_type'],
                  ['buyer_id', 'buyer_id'],
                  ['extra', 'extra']
                ],
                constructor: Proc.new { |good_type, good_id, number, buyer_type, buyer_id, extra| ServeFee.new(
                  good_type, good_id, number: number, buyer_type: buyer_type, buyer_id: buyer_id, extra: self.extra.merge(Hash(extra))
                ) }
    composed_of :promote,
                class_name: 'PromoteFee',
                mapping: [
                  ['good_type', 'good_type'],
                  ['good_id', 'good_id'],
                  ['number', 'number'],
                  ['buyer_type', 'buyer_type'],
                  ['buyer_id', 'buyer_id'],
                  ['extra', 'extra'],
                  ['promote_buyer_ids', 'promote_buyer_ids']
                ],
                constructor: Proc.new { |good_type, good_id, number, buyer_type, buyer_id, extra, promote_buyer_ids|
                  PromoteFee.new(good_type, good_id, number: number, buyer_type: buyer_type, buyer_id: buyer_id, extra: self.extra.merge(Hash(extra)), promote_buyer_ids: promote_buyer_ids)
                }

    def self.extra
      {}
    end
  end

end
