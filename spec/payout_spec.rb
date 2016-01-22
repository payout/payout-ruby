RSpec.describe Payout do
  describe '::api_url' do
    subject { Payout.api_url }

    context 'without having set value' do
      it { is_expected.to eq 'https://live.payout.com' }
    end

    context 'with it having been set to nil' do
      before { Payout.api_url = nil }
      it { is_expected.to eq 'https://live.payout.com' }
    end

    context 'with it having been sent to sandbox url' do
      before { Payout.api_url = 'https://sandbox.payout.com' }
      it { is_expected.to eq 'https://sandbox.payout.com' }
    end

    context 'with trailing forward-slash in url' do
      before { Payout.api_url = 'https://sandbox.payout.com/' }

      it 'should remove trailing forward-slash' do
        is_expected.to eq 'https://sandbox.payout.com'
      end
    end
  end # ::api_url

  describe '::api_token' do
    subject { Payout.api_token }

    context 'without having set a value' do
      it 'should raise AuthenticationError' do
        expect { subject }.to raise_error Payout::AuthenticationError,
          'Payout.api_token must be defined'
      end
    end

    context 'with it being set to valid value' do
      before { Payout.api_token = 'validtoken' }
      it { is_expected.to eq 'validtoken' }
    end
  end # ::api_token

  describe '::api_secret' do
    subject { Payout.api_secret }

    context 'without having set a value' do
      it 'should raise AuthenticationError' do
        expect { subject }.to raise_error Payout::AuthenticationError,
          'Payout.api_secret must be defined'
      end
    end

    context 'with it being set to valid value' do
      before { Payout.api_secret = 'validtoken' }
      it { is_expected.to eq 'validtoken' }
    end
  end # ::api_secret

  describe '::open_timeout' do
    subject { Payout.open_timeout }

    context 'without having set a value' do
      it { is_expected.to eq 30 }
    end

    context 'with having been set to 15' do
      before { Payout.open_timeout = 15 }
      it { is_expected.to eq 15 }
    end

    context 'with being set to 15.0' do
      it 'should raise ArgumentError' do
        expect { Payout.open_timeout = 15.0 }.to raise_error ArgumentError,
          'must be an integer'
      end
    end

    context 'with being set to "seven"' do
      it 'should raise ArgumentError' do
        expect { Payout.open_timeout = 'seven' }.to raise_error ArgumentError,
          'must be an integer'
      end
    end
  end # ::open_timeout

  describe '::read_timeout' do
    subject { Payout.read_timeout }

    context 'without having set a value' do
      it { is_expected.to eq 80 }
    end

    context 'with having been set to 15' do
      before { Payout.read_timeout = 15 }
      it { is_expected.to eq 15 }
    end

    context 'with being set to 15.0' do
      it 'should raise ArgumentError' do
        expect { Payout.read_timeout = 15.0 }.to raise_error ArgumentError,
          'must be an integer'
      end
    end

    context 'with being set to "seven"' do
      it 'should raise ArgumentError' do
        expect { Payout.read_timeout = 'seven' }.to raise_error ArgumentError,
          'must be an integer'
      end
    end
  end # ::read_timeout

  describe '::request' do
    subject { Payout.request(verb, path, params) }
    let(:verb) { :get }
    let(:params) { {} }
    let(:path) { '/test_path' }

    before do
      Payout.api_token = api_token
      Payout.api_secret = api_secret
    end

    let(:api_token) { 'api_token' }
    let(:api_secret) { 'api_secret' }

    it 'should set verify_ssl to verify peer' do
      should_request_with(verify_ssl: OpenSSL::SSL::VERIFY_PEER)
    end

    it 'should set ssl_ca_file to Payout::SSL_CA_FILE' do
      should_request_with(ssl_ca_file: Payout::SSL_CA_FILE)
    end

    context 'with open_timeout unset' do
      it { should_request_with(open_timeout: 30) }
    end

    context 'with open_timeout = 11' do
      before { Payout.open_timeout = 11 }
      it { should_request_with(open_timeout: 11) }
    end

    context 'with read_timeout unset' do
      it { should_request_with(read_timeout: 80) }
    end

    context 'with read_timeout = 11' do
      before { Payout.read_timeout = 11 }
      it { should_request_with(read_timeout: 11) }
    end

    context 'with verb = :get' do
      let(:verb) { :get }
      it { should_request_with(method: :get) }

      context 'with params = nil' do
        let(:params) { nil }

        it 'should not pass params in headers' do
          should_request_with(headers: hash_excluding(:params))
        end
      end

      context 'with params = {}' do
        let(:params) { {} }

        it 'should not pass params in headers' do
          should_request_with(headers: hash_excluding(:params))
        end
      end

      context 'with unempty params' do
        let(:params) { { a: 1, b: 2, c: 3 } }

        it 'should pass params in headers' do
          should_request_with(headers: hash_including(params: params))
        end
      end
    end # with verb = :get

    context 'with verb = :delete' do
      let(:verb) { :delete }
      it { should_request_with(method: :delete) }

      context 'with params = nil' do
        let(:params) { nil }

        it 'should not pass params in headers' do
          should_request_with(headers: hash_excluding(:params))
        end
      end

      context 'with params = {}' do
        let(:params) { {} }

        it 'should not pass params in headers' do
          should_request_with(headers: hash_excluding(:params))
        end
      end

      context 'with unempty params' do
        let(:params) { { a: 1, b: 2, c: 3 } }

        it 'should pass params in headers' do
          should_request_with(headers: hash_including(params: params))
        end
      end
    end # with verb = :delete

    context 'with verb = :post' do
      let(:verb) { :post }
      it { should_request_with(method: :post) }

      context 'with params = nil' do
        let(:params) { nil }

        it 'should pass nil payload' do
          should_request_with(payload: nil)
        end
      end

      context 'with params = {}' do
        let(:params) { {} }

        it 'should pass nil payload' do
          should_request_with(payload: nil)
        end
      end

      context 'with unempty params' do
        let(:params) { { a: 1, b: 2, c: 3 } }

        it 'should pass params as JSON payload' do
          should_request_with(payload: params.to_json)
        end

        it 'should set Content-Type: application/json' do
          should_request_with(
            headers: hash_including(content_type: 'application/json')
          )
        end
      end
    end # with verb = :post

    context 'with verb = :put' do
      let(:verb) { :put }
      it { should_request_with(method: :put) }

      context 'with params = nil' do
        let(:params) { nil }

        it 'should pass nil payload' do
          should_request_with(payload: nil)
        end
      end

      context 'with params = {}' do
        let(:params) { {} }

        it 'should pass nil payload' do
          should_request_with(payload: nil)
        end
      end

      context 'with unempty params' do
        let(:params) { { a: 1, b: 2, c: 3 } }

        it 'should pass params as JSON payload' do
          should_request_with(payload: params.to_json)
        end

        it 'should set Content-Type: application/json' do
          should_request_with(
            headers: hash_including(content_type: 'application/json')
          )
        end
      end
    end # with verb = :put

    context 'with verb = :bad' do
      let(:verb) { :bad }

      it 'should raise ArgumentError' do
        expect { subject }.to raise_error ArgumentError,
          'invalid request verb: :bad'
      end
    end # with verb = :bad

    context 'with path without initial forward-slash' do
      let(:path) { 'test_path' }

      it 'should build URL correctly' do
        should_request_with(url: "https://live.payout.com/#{path}")
      end
    end
  end # ::request
end # Payout
