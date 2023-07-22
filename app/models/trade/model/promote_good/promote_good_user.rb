module Trade
  module Model::PromoteGood::PromoteGoodUser
    extend ActiveSupport::Concern

    included do
      attribute :use_limit, :integer, default: 1

      belongs_to :user, class_name: 'Auth::User', counter_cache: :promote_goods_count, optional: true
      belongs_to :member, class_name: 'Org::Member', counter_cache: :promote_goods_count, optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      before_validation :sync_user, if: -> { member_id_changed? }
    end

    def sync_user
      self.user = self.member&.user
    end

  end
end
