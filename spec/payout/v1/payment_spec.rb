module Payout
  module V1
    RSpec.describe Payment do
      let(:token) { 'CCv395hufwwBlcz' }

      describe '::search' do
        subject { Payment.search(params) }

        context 'with reference_id' do
          let(:params) { { reference_id: 'my_reference_id' } }
          it { should_request_with(:get, '/v1/payments', params) }
        end

        context 'with page' do
          let(:params) { { page: '2' } }
          it { should_request_with(:get, '/v1/payments', params) }
        end
      end # ::search

      describe '::retrieve' do
        subject { Payment.retrieve(token) }
        it { should_request_with(:get, "/v1/payments/#{token}") }
      end # ::retrieve
    end # Balance
  end # V1
end # Payout
