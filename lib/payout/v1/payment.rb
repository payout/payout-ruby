module Payout
  module V1::Payment
    class << self
      def search(params)
        Payout.request(:get, '/v1/payments', params)
      end

      def retrieve(token)
        Payout.request(:get, "/v1/payments/#{token}")
      end
    end
  end # V1::Card
end # Payout
