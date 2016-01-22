require 'payout/version'
require 'json'
require 'base64'
require 'openssl'
require 'rest-client'

module Payout
  autoload(:V1, 'payout/v1')

  class Error < StandardError; end
  class AuthenticationError < Error; end
  class VersionError < Error; end

  DEFAULT_API_VERSION = 1
  DEFAULT_OPEN_TIMEOUT = 30
  DEFAULT_READ_TIMEOUT = 80
  SSL_CA_FILE = File.expand_path('../../data/ca-file.crt', __FILE__).freeze

  class << self
    def version
      VERSION
    end

    def api_version
      if const_defined?(:API_VERSION)
        API_VERSION
      else
        self.api_version = DEFAULT_API_VERSION
      end
    end

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
      @open_timeout || DEFAULT_OPEN_TIMEOUT
    end

    def read_timeout
      @read_timeout || DEFAULT_READ_TIMEOUT
    end

    def api_version=(version)
      fail ArgumentError, 'must be an integer' unless version.is_a?(Integer)
      fail ArgumentError, 'must be a positive integer' unless version > 0

      _include_version(version)
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

    def const_missing(name)
      super if const_defined?(:API_VERSION)
      self.api_version = DEFAULT_API_VERSION
      super unless const_defined?(name)
      const_get(name)
    end

    def _include_version(version)
      if const_defined?(:API_VERSION)
        fail VersionError, 'cannot change version after it has been initialized'
      end

      unless (version_const = "V#{version}") && const_defined?(version_const)
        fail ArgumentError, 'unsupported version'
      end

      include const_get(version_const)

      const_set(:API_VERSION, version)
    end

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
