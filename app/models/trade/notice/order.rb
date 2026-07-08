module Trade
  module Notice::Order
    extend ActiveSupport::Concern

    included do
      after_save_commit :to_organ_notice, if: -> { saved_change_to_payment_status? && payment_status == 'all_paid' }
      after_save_commit :to_provider_notice, if: -> { saved_change_to_state? && state == 'produced' }
    end

    def to_notice
      to_notification(
        user: user,
        title: '您的订单已准备好',
        body: '您的订单将按时到达配送点',
        link: Rails.app.routes.url_for(
          controller: 'trade/board/orders',
          action: 'show',
          id: id
        ),
        verbose: true,
        organ_id: organ_id
      )
    end

    def to_organ_notice
      return unless organ
      organ.ancestral_members.where('notifiable_types ? :type', type: self.base_class_name).each do |member|
        to_member_notice(
          member: member,
          title: "收到新订单 #{note}",
          body: '您的订单将按时到达配送点',
          link: Rails.app.routes.url_for(
            controller: 'trade/admin/orders',
            action: 'show',
            id: id,
            host: organ.admin_host
          ),
          verbose: true
        )
      end
    end

    def to_provider_notice
      return unless organ
      organ.provider.members.where('notifiable_types ? :type', type: self.base_class_name).each do |member|
        to_member_notice(
          member: member,
          title: "收到新订单 #{note}",
          body: '订单已准备好',
          link: Rails.app.routes.url_for(
            controller: 'trade/admin/orders',
            action: 'show',
            id: id,
            host: organ.admin_host
          ),
          code: 'produced',
          verbose: true
        )
      end
    end

  end
end
