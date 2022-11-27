module Trade
  module Inner::User
    extend ActiveSupport::Concern

    included do
      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :client, class_name: 'Profiled::Profile', optional: true



    end

  end
end
