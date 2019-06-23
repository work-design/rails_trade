module RailsTrade::Promote
  extend ActiveSupport::Concern
  included do
    attribute :start_at, :datetime
    attribute :finish_at, :datetime
    attribute :sequence, :integer, default: 1
    attribute :verified, :boolean, default: false
    attribute :default, :boolean, default: false  # 默认直接添加的服务
    
    belongs_to :deal, polymorphic: true, optional: true
    has_many :promote_charges, dependent: :delete_all
    has_many :promote_goods, dependent: :destroy
    has_many :promote_buyers, dependent: :destroy
    
    scope :verified, -> { where(verified: true) }
    scope :default, -> { verified.where(default: true) }
    scope :for_sale, -> { verified.where(default: false) }
    scope :valid, -> { t = Time.now; verified.default_where('start_at-lte': t, 'finish_at-gte': t) }

    validates :code, uniqueness: true, allow_blank: true
    
    after_save :sync_to_extras
    after_commit :delete_cache, on: [:create, :destroy]
    after_update_commit :delete_cache, if: -> { saved_change_to_sequence? }
  
    enum scope: {
      single: 'single',  # 适用于单独计算商品
      overall: 'overall' # 适用于多个商品一起计算
    }
    enum metering: {
      number: 'number',  # 商品购买件数
      weight: 'weight',  # 商品总重量，support sequence
      volume: 'volume',  # 商品总体积, support sequence
      amount: 'amount'  # 商品总金额, support sequence
    }
  end
  
  def sync_to_extras
    promote_extras.pluck(:column_names)
  end

  private
  def delete_cache
    ['promotes/sequence'].each do |c|
      Rails.cache.delete(c)
    end
  end

  class_methods do
    def sequence
      Rails.cache.fetch('promotes/sequence') do
        self.select(:sequence).distinct.pluck(:sequence).sort
      end
    end
  end

end
