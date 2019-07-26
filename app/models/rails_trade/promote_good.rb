module RailsTrade::PromoteGood
  extend ActiveSupport::Concern
  
  included do
    attribute :promote_id, :integer
    attribute :good_id, :integer
    attribute :good_type, :string
    attribute :status, :string, default: 'available'

    belongs_to :promote
    belongs_to :good, polymorphic: true, optional: true
    has_many :promote_buyers, dependent: :delete_all
    
    scope :valid, -> { where(status: ['default', 'available']) }
    
    enum status: {
      default: 'default',  # 默认直接添加的服务，不可取消
      available: 'available',  # 可选
      unavailable: 'unavailable'  # 不可选
    }
    
    validates :promote_id, uniqueness: { scope: [:good_type, :good_id] }
  end

end
