module Payout
  module V1::Balance
    class << self
      def retrieve
        Payout.request(:get, '/v1/balance')
      end

      def update(params)
        Payout.request(:put, '/v1/balance', params)
      end
    end
  end # V1::Card
end # Payout
