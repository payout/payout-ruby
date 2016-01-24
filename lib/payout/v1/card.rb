module Payout
  module V1::Card
    class << self
      def retrieve(token)
        Payout.request(:get, "/v1/cards/#{token}")
      end

      def tokenize(params)
        Payout.request(:post, '/v1/cards', params)
      end

      def update_customer(params)
        token, params = _extract_token(params.dup)
        Payout.request(:put, "/v1/cards/#{token}/customer", params)
      end

      def credit(params)
        token, params = _extract_token(params.dup)
        Payout.request(:post, "/v1/cards/#{token}/credits", params)
      end

      private

      def _extract_token(params)
        token = params.delete(:card_token) or
          fail ArgumentError, 'missing card_token'

        [token, params]
      end
    end
  end # V1::Card
end # Payout
