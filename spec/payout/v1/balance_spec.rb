module Payout
  module V1
    RSpec.describe Balance do
      describe '::retrieve' do
        subject { Balance.retrieve }
        it { should_request_with(:get, '/v1/balance') }
      end # ::retrieve

      describe '::update' do
        subject { Balance.update(params) }

        context 'with valid params' do
          let(:params) { { balance: 10_000_00 } }
          it { should_request_with(:put, '/v1/balance', params) }
        end
      end # ::update
    end # Balance
  end # V1
end # Payout
