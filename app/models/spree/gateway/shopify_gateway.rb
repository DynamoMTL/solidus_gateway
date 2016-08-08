module Spree
  class Gateway::ShopifyGateway < Gateway
    preference :api_key, :string
    preference :password, :string
    preference :shop_name, :string
    preference :shared_secret, :string
    # Reimburse

    # Should all this logic be a active_merchant/billing/gateways/ instead of directly the gateway?
    def credit(money, transaction_id, gateway_options)
      configure_shopify_api!
      refund = gateway_options[:originator]
      transaction = ::ShopifyAPI::Transaction.find(transaction_id)
      if BigDecimal.new(money.to_s) == (transaction.amount * 100)
        full_refund_on_shopify(refund, transaction)
      elsif BigDecimal.new(money.to_s) < (transaction.amount * 100)
        raise NotImplementedError
      else
        raise NotImplementedError
      end
    end

    def void(transaction_id, gateway_options)
      configure_shopify_api!
      # Figure out how to directly do a post request instead of get and post
      transaction = ::ShopifyAPI::Transaction.find(transaction_id)
      transaction.kind = 'void'
      transaction.save
    end

    def cancel(transaction_id)
      configure_shopify_api!
      # Figure out how to directly do a post request instead of get and post
      transaction = ::ShopifyAPI::Transaction.find(transaction_id)
      transaction.kind = 'void'
      transaction.save
    end

    private

    def full_refund_on_shopify(refund, transaction)
      transaction = ::ShopifyAPI::Refund.calculate({ shipping: { full_refund: true } },
                                                   params: { order_id: transaction.order_id })

      ::ShopifyAPI::Refund.create({ shipping: { full_refund: true },
                                    note: refund.reason.name,
                                    notify: false,
                                    restock: false,
                                    transaction: transaction },
                                  params: { order_id: transaction.order_id })
    end

    def configure_shopify_api!
      ::ShopifyAPI::Base.site = shopify_shop_url
    end

    def shopify_shop_url
      "https://#{preferred_api_key}:#{preferred_password}@#{preferred_shop_name}"
    end
  end
end
