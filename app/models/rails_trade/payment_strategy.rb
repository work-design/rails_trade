module RailsTrade::PaymentStrategy
  extend ActiveSupport::Concern
  included do
    attribute :name, :string # 名称
    attribute :period, :integer #可延期时间，单位天
    
    enum xx: {
      # 预付全款
      # 预付定金
      # 后付
    }
  end
  
  def credit?
    self.period.to_i > 0
  end

end
