module Spree
  class Gateway::ShopifyGateway < Gateway
    preference :api_key, :string
    preference :password, :string
    preference :shop_name, :string

    def provider_class
      ActiveMerchant::Billing::ShopifyGateway
    end

    def method_type
      'shopify'
    end

    def credit(money, transaction_id, gateway_options)
      refund = gateway_options[:originator]
      options = { order_id: refund.pos_order_id, reason: refund.reason.name }
      provider.refund(money, transaction_id, options)
    end

    def void(transaction_id, gateway_options)
      pos_order_id = gateway_options[:originator].pos_order_id
      provider.void(transaction_id, order_id: pos_order_id)
    end

    def cancel(_transaction_id)
      # NOTE(cab): I am unsure how we can achieve that, since we are required
      # to have the order_id in order to call the Shopify API.
      raise NotImplementedError
    end
  end
end
