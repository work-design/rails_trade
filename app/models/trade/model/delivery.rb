module Trade
  module Model::Delivery
    extend ActiveSupport::Concern

    included do
      attribute :fetch_oneself, :boolean, default: false, comment: '自取'
      attribute :fetch_start_at, :datetime
      attribute :fetch_finish_at, :datetime
      attribute :produce_on, :date, comment: '对接生产管理'

      enum state: {
        init: 'init'
      }

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :user, class_name: 'Auth::User', optional: true
      belongs_to :member, class_name: 'Org::Member', optional: true
      belongs_to :member_organ, class_name: 'Org::Organ', optional: true
      belongs_to :client, class_name: 'Profiled::Profile', optional: true

      belongs_to :scene, class_name: 'Factory::Scene', optional: true

      belongs_to :order, optional: true

      has_many :items, ->(o) { where(o.filter_hash) }, primary_key: :user_id, foreign_key: :user_id
    end

    def filter_hash
      if user_id
        { organ_id: organ_id, member_id: member_id }
      elsif client_id
        { organ_id: organ_id, member_id: member_id, client_id: client_id }
      else
        { organ_id: organ_id, member_id: member_id }
      end
    end

    def fetch_include?(start_time, finish_time)
      return nil if fetch_start_at.blank?
      start = fetch_start_at.to_fs(:time)
      finish = fetch_finish_at.to_fs(:time)

      start <= start_time && finish >= finish_time
    end

  end
end
