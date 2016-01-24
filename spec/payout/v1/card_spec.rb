module Payout
  module V1
    RSpec.describe Card do
      let(:token) { 'CTxb2czBhlBrFQSQeabm8bTo' }

      describe '::retrieve' do
        subject { Card.retrieve(token) }
        it { should_request_with(:get, '/v1/cards/%s' % token) }
      end # ::retrieve

      describe '::tokenize' do
        subject { Card.tokenize(params) }

        context 'with required card params' do
          let(:params) do
            {
              name: 'John Smith',
              card_number: '4111111111111111',
              exp_month: '08',
              exp_year: '20'
            }
          end

          it { should_request_with(:post, '/v1/cards', params) }
        end
      end # ::tokenize

      describe '::credit' do
        subject { Card.credit(params) }

        context 'with valid params' do
          let(:params) do
            {
              card_token: token,
              amount: 100
            }
          end

          it 'should make expected request' do
            should_request_with(:post, '/v1/cards/%s/credits' % token, params)
          end
        end

        context 'with card_token missing' do
          let(:params) { { amount: 100 } }

          it 'should raise error ArgumentError' do
            expect { subject }.to raise_error ArgumentError,
              'missing card_token'
          end
        end
      end # ::credit
    end # Card
  end # V1
end # Payout
