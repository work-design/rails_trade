module RailsTrade::Promote
  extend ActiveSupport::Concern
  included do
    attribute :start_at, :datetime
    attribute :finish_at, :datetime
    attribute :sequence, :integer, default: 1
    attribute :verified, :boolean, default: false
    attribute :editable, :boolean, default: false  # 是否可更改价格
    
    belongs_to :deal, polymorphic: true, optional: true
    has_many :promote_charges, dependent: :delete_all
    has_many :promote_extras, dependent: :delete_all
    has_many :promote_goods, dependent: :destroy
    has_many :promote_buyers, dependent: :destroy
    
    scope :verified, -> { where(verified: true) }
    scope :default, -> { verified.where(default: true) }
    scope :for_sale, -> { verified.where(default: false) }
    scope :valid, -> { t = Time.now; verified.default_where('start_at-lte': t, 'finish_at-gte': t) }

    validates :code, uniqueness: true, allow_blank: true
    
    after_commit :delete_cache, on: [:create, :destroy]
    after_update_commit :delete_cache, if: -> { saved_change_to_sequence? }
  
    enum scope: {
      single: 'single',  # 适用于单独计算商品
      overall: 'overall' # 适用于多个商品一起计算
    }
  end
  
  def extra_mappings
    x = promote_extras.pluck(:extra_name, :column_name).to_h
  end

  def compute_charge(value, metering, extra: {})
    extra.transform_keys! { |key| extra_mappings[key.to_s] }
    extra.delete nil
    
    q_params = {
      metering: metering,
      'min-lte': value,
      'max-gte': value,
      **extra
    }
  
    charges = promote_charges.default_where(q_params)
    charges = charges.reject do |charge|
      (charge.max == value && !charge.contain_max) || (charge.min == value && !charge.contain_min)
    end
    charges.first
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
