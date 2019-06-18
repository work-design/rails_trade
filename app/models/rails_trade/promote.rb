module RailsTrade::Promote
  extend ActiveSupport::Concern
  included do
    attribute :extra, :string, array: true
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
  
    after_commit :delete_cache, on: [:create, :destroy]
    after_update_commit :delete_cache, if: -> { saved_change_to_sequence? }
  
    enum scope: {
      total: 'total', # 适用于多个商品一起计算
      single: 'single'  # 适用于单独计算商品
    }
  end
  
  def compute_charge(amount, extra_hash = {})
    extra_hash.stringify_keys!

    query = { 'min-lte': amount.to_d, 'max-gte': amount.to_d }.merge(extra_hash.slice(*extra))
    charges = self.promote_charges.default_where(query)
    charges.reject! do |charge|
      (charge.max == amount && !charge.contain_max) ||
      (charge.min == amount && !charge.contain_min)
    end
    charge = charges.first

    [charge, -(amount - charge.final_price(amount))] if charge
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
