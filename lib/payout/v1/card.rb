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
        params = params.dup
        token = params.delete(:card_token) or
          fail ArgumentError, 'missing card_token'

        Payout.request(:put, "/v1/cards/#{token}/customer", params)
      end

      def credit(params)
        params = params.dup
        token = params.delete(:card_token) or
          fail ArgumentError, 'missing card_token'

        Payout.request(:post, "/v1/cards/#{token}/credits", params)
      end
    end
  end # V1::Card
end # Payout
