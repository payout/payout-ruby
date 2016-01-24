require 'json'

##
# Wraps a RestClient response to provide the Payout SDK interface.
module Payout
  class Response
    class << self
      # Handles the response from RestClient, including any errors that may be
      # raised.
      def handle
        new(yield)
      rescue SocketError => e
        _handle_restclient_connection_error(e)
      rescue RestClient::ExceptionWithResponse => e
        _handle_error_with_response(e)
      rescue RestClient::Exception, Errno::ECONNREFUSED => e
        _handle_restclient_connection_error(e)
      end

      private

      def _handle_restclient_connection_error(error)
        case error
        when RestClient::RequestTimeout
          fail TimeoutError
        when RestClient::ServerBrokeConnection
          fail ConnectionError, 'The server broke the connection before the ' \
            'request could complete.'
        when RestClient::SSLCertificateNotVerified
          fail ConnectionError, 'Failed to verify SSL certificate.'
        when SocketError
          fail ConnectionError, 'An unexpected error occurred when trying to ' \
            'connect to Payout. This could be a DNS issue. Check that you can ' \
            'resolve live.payout.com and/or sandbox.payout.com.'
        else
          fail ConnectionError, 'An unexpected error occurred when trying to ' \
            'connect to Payout. Try again or contact us at support@payout.com.'
        end
      end

      def _handle_error_with_response(error)
        if (resp = error.response)
          fail AuthenticationError, 'invalid credentials' if resp.code == 401
          new(resp)
        else
          _handle_restclient_connection_error(error)
        end
      end
    end # Class Methods

    attr_reader :code
    attr_reader :body

    def initialize(response)
      @code = response.code
      @body = response.body
      _parse(response.body)
    end

    def successful?
      [200, 201].include?(code)
    end

    def [](key)
      @_data[key]
    end

    def to_h
      @_data.dup
    end

    private

    def _parse(body)
      @_data = JSON.parse(body || '{}', symbolize_names: true)
    rescue JSON::ParserError
      @_data = {}
    end
  end
end
