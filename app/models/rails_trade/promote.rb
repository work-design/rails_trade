module RailsTrade::Promote
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :short_name, :string
    attribute :code, :string
    attribute :description, :string
    attribute :scope, :string
    attribute :metering, :string
    attribute :effect_at, :datetime
    attribute :expire_at, :datetime
    attribute :sequence, :integer, default: 1
    attribute :editable, :boolean, default: false, comment: '是否可更改价格'
    
    belongs_to :organ, optional: true
    belongs_to :deal, polymorphic: true, optional: true
    has_many :promote_charges, dependent: :delete_all
    has_many :promote_extras, dependent: :delete_all
    has_many :promote_goods, dependent: :destroy
    has_many :promote_buyers, dependent: :destroy
    
    scope :verified, -> { where(verified: true) }
    scope :default, -> { verified.where(default: true) }
    scope :for_sale, -> { verified.where(default: false) }
    scope :valid, -> { t = Time.current; verified.default_where('effect_at-lte': t, 'expire_at-gte': t) }

    validates :code, uniqueness: true, allow_blank: true
    
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
  
  def extra_mappings
    promote_extras.pluck(:extra_name, :column_name).to_h
  end

  def compute_charge(value, **extra)
    extra.transform_keys! { |key| extra_mappings[key.to_s] }
    extra.delete nil
    
    q_params = {
      'min-lte': value,
      'max-gte': value,
      **extra
    }
    
    promote_charges.default_where(q_params).take
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
