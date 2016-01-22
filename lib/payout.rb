require 'payout/version'
require 'json'
require 'base64'
require 'openssl'
require 'rest-client'

module Payout
  class Error < StandardError; end
  class AuthenticationError < Error; end

  SSL_CA_FILE = File.expand_path('../../data/ca-file.crt', __FILE__).freeze

  class << self
    def api_url
      @api_url || 'https://live.payout.com'
    end

    def api_token
      @api_token || fail(AuthenticationError,
        'Payout.api_token must be defined')
    end

    def api_secret
      @api_secret || fail(AuthenticationError,
        'Payout.api_secret must be defined')
    end

    def open_timeout
      @open_timeout || 30
    end

    def read_timeout
      @read_timeout || 80
    end

    def api_url=(api_url)
      if api_url
        api_url = api_url.dup
        api_url = api_url[0..-2] if api_url[-1] == '/'
      end

      @api_url = api_url.freeze
    end

    def api_token=(token)
      @api_token = token.dup.freeze
    end

    def api_secret=(secret)
      @api_secret = secret.dup.freeze
    end

    def open_timeout=(timeout)
      fail ArgumentError, 'must be an integer' unless timeout.is_a?(Integer)
      @open_timeout = timeout
    end

    def read_timeout=(timeout)
      fail ArgumentError, 'must be an integer' unless timeout.is_a?(Integer)
      @read_timeout = timeout
    end

    def request(verb, path, params = {})
      url = _build_request_url(path)
      headers = _default_headers
      body = nil

      case verb
      when :get, :delete
        headers[:params] = params if params && params.any?
      when :post, :put
        headers[:content_type] = 'application/json'
        body = params.to_json if params && params.any?
      else
        fail ArgumentError, "invalid request verb: #{verb.inspect}"
      end

      _request(
        verify_ssl:   OpenSSL::SSL::VERIFY_PEER,
        ssl_ca_file:  SSL_CA_FILE,
        open_timeout: open_timeout,
        read_timeout: read_timeout,
        method:       verb,
        url:          url,
        headers:      headers,
        payload:      body
      )
    end

    private

    def _build_request_url(path)
      api_url + (path[0] == '/' ? path : "/#{path}")
    end

    def _default_headers
      {
        authorization: "Basic #{_encoded_credentials}"
      }
    end

    def _encoded_credentials
      Base64.strict_encode64("#{api_token}:#{api_secret}")
    end

    def _request(request_opts)
      RestClient::Request.execute(request_opts)
    end
  end # Class Methods
end
