module Trade
  module Model::Delivery
    extend ActiveSupport::Concern
    include Inner::User

    included do
      attribute :fetch_oneself, :boolean, default: false, comment: '自取'
      attribute :fetch_start_at, :datetime
      attribute :fetch_finish_at, :datetime
      attribute :produce_on, :date, comment: '对接生产管理'

      enum state: {
        init: 'init'
      }

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :scene, class_name: 'Factory::Scene'
      belongs_to :produce_plan, ->(o){ where(organ_id: o.organ_id, produce_on: o.produce_on) }, class_name: 'Factory::ProducePlan', foreign_key: :scene_id, primary_key: :scene_id, optional: true  # 产品对应批次号

      belongs_to :order, optional: true

      has_many :items, ->(o) { where(o.filter_hash) }, primary_key: :user_id, foreign_key: :user_id

    end

    def xx

    end

    def filter_hash
      r = { organ_id: organ_id, member_id: member_id, produce_on: produce_on, scene_id: scene_id }
      if user_id
        r
      elsif client_id
        r.merge! client_id: client_id
      else
        r
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
