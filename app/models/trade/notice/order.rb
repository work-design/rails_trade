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
        link: Rails.application.routes.url_for(
          controller: 'trade/board/orders',
          action: 'show',
          id: id
        ),
        verbose: true,
        organ_id: organ_id
      )
    end

    def to_provider_notice
      return unless organ
      organ.ancestral_members.wechat.default_where('notifiable_types-any': self.base_class_name).each do |member|
        to_member_notice(
          member: member,
          title: "收到新订单 #{note}",
          body: '您的订单将按时到达配送点',
          link: Rails.application.routes.url_for(
            controller: 'trade/admin/orders',
            action: 'show',
            id: id,
            host: organ.admin_host
          ),
          verbose: true
        )
      end
    end

  end
end
