require 'spec_helper'

describe Spree::Gateway::ShopifyGateway do
  let(:api_key) { '5ea25b239cdbe5df107b7ff2c366b5de' }
  let(:password) { '0343a464bacb8ceff405e6e4e4b88ff3' }
  let(:shop_name) { 'dynamo-staging.myshopify.com/admin' }
  let(:shared_secret) { '3781b32c2fb712e5a4f90a1a1bb8e0a397527d0e3530f755c41b28d0b2ee5c11' }

  let(:gateway) do
    gateway = described_class.new(active: true)
    gateway.set_preference(:api_key, api_key)
    gateway.set_preference(:password, password)
    gateway.set_preference(:shop_name, shop_name)
    gateway.set_preference(:shared_secret, shared_secret)
    gateway
  end

  let!(:store) { FactoryGirl.create(:store) }
  let(:order) { Spree::Order.create! }

  let(:card) do
    FactoryGirl.create(
      :credit_card,
      gateway_customer_profile_id: 'cus_abcde',
      imported: false
    )
  end

  let(:payment) do
    payment = Spree::Payment.new
    payment.source = card
    payment.order = order
    payment.payment_method = gateway
    payment.amount = 54
    payment.state = 'pending'
    payment.response_code = '12345'
    payment
  end

  context '.void' do
    let(:shopify_transaction) { double('shopify_transaction') }
    let(:transaction_id) { 1 }

    before do
      allow(::ShopifyAPI::Transaction).to receive(:find).and_return(shopify_transaction)
    end

    it 'calls save on the shopify transaction once' do
      expect(shopify_transaction).to receive(:save).once
      void!(transaction_id, nil)
    end

    private

    def void!(transaction_id, gateway_options)
      subject.void(transaction_id, gateway_options)
    end
  end

  context '.cancel' do
    let(:shopify_transaction) { double('shopify_transaction') }
    let(:transaction_id) { 1 }

    before do
      allow(::ShopifyAPI::Transaction).to receive(:find).and_return(shopify_transaction)
    end

    it 'calls save on the shopify transaction once' do
      expect(shopify_transaction).to receive(:save).once
      cancel!(transaction_id)
    end

    private

    def cancel!(transaction_id)
      subject.cancel(transaction_id)
    end
  end

  context '.credit' do
    let(:amount) { 48 }
    let(:amount_in_cents) { amount * 100 }
    let(:shopify_order_id) { 3910455495 }
    let(:transaction_id) { 1 }

    let(:shopify_transaction) do
      double('shopify_transaction').tap do |s_t|
        allow(s_t).to receive(:amount).and_return(amount)
        allow(s_t).to receive(:order_id).and_return(shopify_order_id)
      end
    end

    before do
      allow(::ShopifyAPI::Transaction).to receive(:find).and_return(shopify_transaction)
      allow(::ShopifyAPI::Refund).to receive(:calculate).and_return(shopify_transaction)
      allow(::ShopifyAPI::Refund).to receive(:create).and_return(true)
    end

    context 'all line items' do
      context 'with a full refund' do
        let(:reason) { FactoryGirl.create(:refund_reason) }
        # let(:return_item) { build(:return_item, inventory_unit: inventory_unit) }
        # let(:customer_return) { build(:customer_return, return_items: [return_item]) }
        # let(:reimbursement) { FactoryGirl.create(:reimbursement, refunds: refund) }

        let(:refund) do
          refund = Spree::Refund.new
          refund.payment = payment
          refund.reason = reason
          refund.amount = payment.amount
          refund.transaction_id = nil

          refund
        end

        it 'calls the shopify calculate refund method once' do
          expect(::ShopifyAPI::Refund).to receive(:calculate).once
          refund!(amount_in_cents, transaction_id, refund)
        end

        it 'calls the shopify calculate create method once' do
          expect(::ShopifyAPI::Refund).to receive(:create).once
          refund!(amount_in_cents, transaction_id, refund)
        end
      end
    end
  end

  private

  def refund!(amount_in_cents, transaction_id, refund)
    subject.credit(amount_in_cents, transaction_id, originator: refund)
  end
end
