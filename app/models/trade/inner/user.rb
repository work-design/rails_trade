module Trade
  module Inner::User
    extend ActiveSupport::Concern

    included do
      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true

      before_validation :sync_member_organ, if: -> { member_id_changed? }
    end

    def sync_member_organ
      self.member_organ_id = member&.organ_id
    end

  end
end
