module Payout
  RSpec.describe Response do
    describe '::handle' do
      subject { Response.handle(&request_block) }

      class << self
        def def_request_block(&block)
          let(:request_block) { block }
        end

        def with_request_returning(code, body = nil)
          case code
          when 200, 201
            def_request_block do
              # Need to define double within block, so it's unique per test.
              RSpec::Mocks::Double.new('response', code: code, body: body)
            end
          else
            def_request_block do
              # Need to define double within block, so it's unique per test.
              r = RSpec::Mocks::Double.new('response', code: code, body: body)
              fail RestClient::ExceptionWithResponse.new(r)
            end
          end
        end
      end # Test Helpers

      context 'with SocketError raised' do
        def_request_block { fail SocketError }

        it 'should raise ConnectionError with appropriate message' do
          expect { subject }.to raise_error ConnectionError, 'An unexpected ' \
            'error occurred when trying to connect to Payout. This could be a '\
            'DNS issue. Check that you can resolve live.payout.com and/or ' \
            'sandbox.payout.com.'
        end
      end

       context 'with RestClient::ExceptionWithResponse raised w/out response' do
        def_request_block { fail RestClient::ExceptionWithResponse }

        it 'should raise a connection error' do
          expect { subject }.to raise_error ConnectionError, 'An unexpected ' \
            'error occurred when trying to connect to Payout. Try again or ' \
            'contact us at support@payout.com.'
        end
      end

      context 'with RestClient::RequestTimeout raised' do
        def_request_block { fail RestClient::RequestTimeout }

        it 'should raise Payout::TimeoutError' do
          expect { subject }.to raise_error TimeoutError
        end
      end

      context 'with RestClient::ServerBrokeConnection raised' do
        def_request_block { fail RestClient::ServerBrokeConnection }

        it 'should raise ConnectionError' do
          expect { subject }.to raise_error ConnectionError, 'The server ' \
            'broke the connection before the request could complete.'
        end
      end

      context 'with RestClient::SSLCertificateNotVerified raised' do
        def_request_block { fail RestClient::SSLCertificateNotVerified.new('') }

        it 'should raise ConnectionError' do
          expect { subject }.to raise_error ConnectionError, 'Failed to ' \
            'verify SSL certificate.'
        end
      end

      context 'with Errno::ECONNREFUSED raised' do
        def_request_block { fail Errno::ECONNREFUSED }

        it 'should raise ConnectionError' do
          expect { subject }.to raise_error ConnectionError, 'An unexpected ' \
            'error occurred when trying to connect to Payout. Try again or ' \
            'contact us at support@payout.com.'
        end
      end

      context 'with 200 returned' do
        with_request_returning(200, '{"a":1,"b":2,"c":3}')
        it { is_expected.to be_a Response }

        it 'should have expected attributes' do
          is_expected.to have_attributes(
            code: 200,
            successful?: true,
            body: '{"a":1,"b":2,"c":3}',
            to_h: { a: 1, b:2, c: 3 }
          )
        end
      end

      context 'with 201 returned' do
        with_request_returning(201, '{"a":1,"b":2,"c":3}')
        it { is_expected.to be_a Response }

        it 'should have expected attributes' do
          is_expected.to have_attributes(
            code: 201,
            successful?: true,
            body: '{"a":1,"b":2,"c":3}',
            to_h: { a: 1, b:2, c: 3 }
          )
        end
      end

      context 'with 401 returned' do
        with_request_returning(401)

        it 'should raise AuthenticationError' do
          expect { subject }.to raise_error AuthenticationError, 'invalid credentials'
        end
      end

      context 'with 400 returned with error message' do
        with_request_returning(400, '{"error": "some_error"}')
        it { is_expected.to be_a Response }

        it 'should have expected attributes' do
          is_expected.to have_attributes(
            code: 400,
            successful?: false,
            body: '{"error": "some_error"}',
            to_h: { error: 'some_error' }
          )
        end
      end

      context 'with 403 returned with error message' do
        with_request_returning(403, '{"error": "some_error"}')
        it { is_expected.to be_a Response }

        it 'should have expected attributes' do
          is_expected.to have_attributes(
            code: 403,
            successful?: false,
            body: '{"error": "some_error"}',
            to_h: { error: 'some_error' }
          )
        end
      end

      context 'with 404 returned with error message' do
        with_request_returning(404, '{"error": "some_error"}')
        it { is_expected.to be_a Response }

        it 'should have expected attributes' do
          is_expected.to have_attributes(
            code: 404,
            successful?: false,
            body: '{"error": "some_error"}',
            to_h: { error: 'some_error' }
          )
        end
      end

      context 'with 406 returned with error message' do
        with_request_returning(406, '{"error": "some_error"}')
        it { is_expected.to be_a Response }

        it 'should have expected attributes' do
          is_expected.to have_attributes(
            code: 406,
            successful?: false,
            body: '{"error": "some_error"}',
            to_h: { error: 'some_error' }
          )
        end
      end
    end # ::handle

    context '#code' do
      let(:code) { rand(500) + 100 }
      let(:response) { double('response', code: code, body: nil) }
      subject { Response.new(response).code }

      it 'should equal code passed as response' do
        is_expected.to eq code
      end
    end # #code

    context '#body' do
      let(:body) { '{"message":"%s"}' % SecureRandom.uuid }
      let(:response) { double('response', code: 200, body: body) }
      subject { Response.new(response).body }

      it 'should equal code passed as response' do
        is_expected.to eq body
      end
    end # #body

    context '#to_h' do
      let(:response) { double('response', code: 200, body: body) }
      subject { Response.new(response).to_h }

      context 'with body = "{"hello":"world"}"' do
        let(:body) { '{"hello":"world"}' }
        it { is_expected.to eq(hello: 'world') }
      end

      context 'with body = nil' do
        let(:body) { nil }
        it { is_expected.to eq({}) }
      end

      context 'with body = "{}"' do
        let(:body) { '{}' }
        it { is_expected.to eq({}) }
      end

      context 'with body = ""' do
        let(:body) { '' }
        it { is_expected.to eq({}) }
      end
    end # #to_h

    describe '#successful?' do
      let(:response) { double('response', code: code, body: nil) }
      subject { Response.new(response).successful? }

      context 'with code = 200' do
        let(:code) { 200 }
        it { is_expected.to be true }
      end

      context 'with code = 201' do
        let(:code) { 201 }
        it { is_expected.to be true }
      end

      context 'with code = 400' do
        let(:code) { 400 }
        it { is_expected.to be false }
      end

      context 'with code = 403' do
        let(:code) { 403 }
        it { is_expected.to be false }
      end

      context 'with code = 404' do
        let(:code) { 404 }
        it { is_expected.to be false }
      end

      context 'with code = 406' do
        let(:code) { 406 }
        it { is_expected.to be false }
      end
    end # #successful?

    describe '#[]' do
      let(:response) { double('response', code: 200, body: body) }
      subject { Response.new(response)[key] }

      context 'with body {"a":1,"b":2,"c":3}' do
        let(:body) { '{"a":1,"b":2,"c":3}' }

        context 'with key = :a' do
          let(:key) { :a }
          it { is_expected.to eq 1 }
        end

        context 'with key = :b' do
          let(:key) { :b }
          it { is_expected.to eq 2 }
        end

        context 'with key = :c' do
          let(:key) { :c }
          it { is_expected.to eq 3 }
        end

        context 'with key = :d' do
          let(:key) { :d }
          it { is_expected.to be nil }
        end

        context 'with key = "a"' do
          let(:key) { 'a' }
          it { is_expected.to be nil }
        end
      end
    end # #[]
  end # Response
end # Payout
