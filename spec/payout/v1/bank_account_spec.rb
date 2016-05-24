module Payout
  module V1
    RSpec.describe BankAccount do
      let(:token) { 'BTxb2czBhlBrFQSQeabm8bTo' }

      describe '::retrieve' do
        subject { BankAccount.retrieve(token) }
        it { should_request_with(:get, '/v1/bank_accounts/%s' % token) }
      end # ::retrieve

      describe '::tokenize' do
        subject { BankAccount.tokenize(params) }

        context 'with required card params' do
          let(:params) do
            {
              name: 'John Smith',
              card_number: '4111111111111111',
              exp_month: '08',
              exp_year: '20'
            }
          end

          it { should_request_with(:post, '/v1/bank_accounts', params) }
        end
      end # ::tokenize

      describe '::update_customer' do
        subject { BankAccount.update_customer(params) }

        context 'with required customer params' do
          let(:params) do
            {
              bank_account_token: token,
              name: 'John Smith',
              address_line1: '1 Stockton St.',
              address_line2: '#123',
              address_city: 'San Francisco',
              address_state: 'CA',
              address_zip: '94108'
            }
          end

          it 'should make expected request' do
            should_request_with(:put, "/v1/bank_accounts/#{token}/customer",
              params.reject { |x| x == :bank_account_token })
          end
        end
      end # ::update_customer

      describe '::credit' do
        subject { BankAccount.credit(params) }

        context 'with valid params' do
          let(:params) do
            {
              bank_account_token: token,
              amount: 100
            }
          end

          it 'should make expected request' do
            should_request_with(:post, '/v1/bank_accounts/%s/credits' % token,
              params.reject { |x| x == :bank_account_token })
          end
        end

        context 'with bank_account_token missing' do
          let(:params) { { amount: 100 } }

          it 'should raise error ArgumentError' do
            expect { subject }.to raise_error ArgumentError,
              'missing bank_account_token'
          end
        end
      end # ::credit
    end # BankAccount
  end # V1
end # Payout
