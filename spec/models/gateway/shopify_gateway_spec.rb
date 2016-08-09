require 'spec_helper'

describe Spree::Gateway::ShopifyGateway do
  let(:transaction_id) { '0xDEADBEEF' }
  let(:pos_order_id) { '0xBAADF00D' }
  let(:refund) { double('refund') }
  let(:gateway_options) { { originator: refund } }

  let(:provider_class) { ActiveMerchant::Billing::ShopifyGateway }

  before do
    allow(refund).to receive(:pos_order_id).and_return(pos_order_id)
  end

  context '.void' do
    it 'calls the provider void method once' do
      expect(provider_class).to receive(:void).once
      void!
    end

    private

    def void!
      subject.void(transaction_id, gateway_options)
    end
  end

  context '.cancel' do
    it 'throws an error because it\'s not implemented' do
      expect { cancel! }.to raise_error(NotImplementedError)
    end

    private

    def cancel!
      subject.cancel(transaction_id)
    end
  end

  context '.credit' do
    let(:amount_in_cents) { '100' }

    it 'calls the provider refund method once' do
      expect(provider_class).to receive(:credit).once
      refund!
    end

    private

    def refund!
      subject.credit(amount_in_cents, transaction_id, originator: refund)
    end
  end
end
