module Trade
  module Notice::Payment
    extend ActiveSupport::Concern

    included do
      acts_as_notify(
        :default,
        only: ['payment_uuid', 'created_at', 'total_amount', 'type', 'buyer_bank'],
        methods: ['type_i18n']
      )

      after_save_commit :to_provider_notice, if: -> { saved_change_to_pay_state? && pay_state == 'paid' }
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
      organ.ancestral_members.wechat.each do |member|
        to_member_notice(
          member: member,
          title: '收到新的支付',
          body: '您的订单将按时到达配送点',
          link: Rails.application.routes.url_for(controller: 'trade/agent/payment_orders', payment_id: id, host: organ.agent_host),
          verbose: true
        )
      end
    end

  end
end
