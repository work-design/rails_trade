module Trade
  module Notice::Order
    extend ActiveSupport::Concern

    included do
      acts_as_notify(
        :default,
        only: ['uuid', 'created_at', 'note']
      )
    end

    def to_notice
      to_notification(
        user: user,
        title: '您的订单已准备好',
        body: '您的订单将按时到达配送点',
        link: Rails.application.routes.url_for(controller: 'trade/board/orders', action: 'show', id: id),
        verbose: true,
        organ_id: organ_id
      )
    end

    def to_provider_notice
      return unless organ&.creator
      to_notification(
        user: organ.creator,
        title: '收到新订单',
        body: '您的订单将按时到达配送点',
        link: Rails.application.routes.url_for(controller: 'trade/admin/orders', action: 'show', id: id, host: organ.admin_host),
        verbose: true,
        organ_id: organ.provider_id
      )
    end

  end
end
