module Payout
  module V1::BankAccount
    class << self
      def retrieve(token)
        Payout.request(:get, "/v1/bank_accounts/#{token}")
      end

      def tokenize(params)
        Payout.request(:post, '/v1/bank_accounts', params)
      end

      def update_customer(params)
        token, params = _extract_token(params.dup)
        Payout.request(:put, "/v1/bank_accounts/#{token}/customer", params)
      end

      def credit(params)
        token, params = _extract_token(params.dup)
        Payout.request(:post, "/v1/bank_accounts/#{token}/credits", params)
      end

      private

      def _extract_token(params)
        token = params.delete(:bank_account_token) or
          fail ArgumentError, 'missing bank_account_token'

        [token, params]
      end
    end
  end # V1::BankAccount
end # Payout
