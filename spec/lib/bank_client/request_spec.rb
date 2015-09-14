describe BankClient::Request do
  describe '#perform' do
    context 'when performing check operation' do
      context 'when parameters are correct' do
        let(:request) do
          BankClient::Request.new(
            target: 'giftdeposit_agent_kass',
            operation: 'check',
            idcard: '9000240319923'
          )
        end

        it 'returns card info' do
          VCR.use_cassette('request/perform_check_success') do
            response = request.perform
            expect(response).to include 'gateway_response'
            expect(response['gateway_response']).not_to include 'error'
            expect(response['gateway_response'].keys).to include 'cardnumber', 'amount', 'comm'
          end
        end
      end

      context 'when parameters are incorrect' do
        let(:request) do
          BankClient::Request.new(
            target: 'giftdeposit_agent_kass',
            operation: 'check',
            idcard: '123123123'
          )
        end

        it 'returns error' do
          VCR.use_cassette('request/perform_check_wrong_card') do
            response = request.perform
            expect(response).to include 'gateway_response'
            expect(response['gateway_response']).to include 'error'
            expect(response['gateway_response']['error']).to include 'code', 'description'
          end
        end
      end

      context 'when timeout happens' do
        let(:request) do
          BankClient::Request.new(
            target: 'giftdeposit_agent_kass',
            operation: 'check',
            idcard: '9000240319923'
          )
        end

        it 'returns correct error' do
          stub_request(:any, /127\.0\.0\.1/).to_timeout
          response = request.perform
          expect(response).to include 'gateway_response'
          expect(response['gateway_response']).to include 'error'
          expect(response['gateway_response']['error']).to include 'code', 'description'
          expect(response['gateway_response']['error']['code']).to eq '-1'
        end
      end
    end

    context 'when performing pay operation' do
      context 'when parameters are correct' do
        let(:request) do
          BankClient::Request.new(
            target: 'giftdeposit_agent_kass',
            operation: 'pay',
            idcard: '9000240319923',
            transaction_id: '12345',
            amount: 100.0
          )
        end

        it 'returns result' do
          VCR.use_cassette('request/perform_pay_success') do
            response = request.perform
            expect(response).to include 'gateway_response'
            expect(response['gateway_response']).not_to include 'error'
            expect(response['gateway_response']).to include 'container'
            expect(response['gateway_response']).to include 'sig'
            container = response['gateway_response']['container']
            expect(container.keys.sort).to include(
              'amount',
              'authcode',
              'card',
              'comm',
              'dateoper',
              'expiry',
              'idlog'
            )
          end
        end
      end

      context 'when parameters are incorrect' do
        let(:request) do
          BankClient::Request.new(
            target: 'giftdeposit_agent_kass',
            operation: 'pay',
            idcard: '9000240319923',
            amount: 100.0
          )
        end

        it 'returns result' do
          VCR.use_cassette('request/perform_pay_wrong_params') do
            response = request.perform
            expect(response).to include 'gateway_response'
            expect(response['gateway_response']).to include 'error'
            expect(response['gateway_response']['error']).to include 'code', 'description'
          end
        end
      end

      context 'when timeout happens' do
        let(:request) do
          BankClient::Request.new(
            target: 'giftdeposit_agent_kass',
            operation: 'pay',
            idcard: '9000240319923',
            amount: 100.0
          )
        end

        it 'returns correct error' do
          stub_request(:any, /127\.0\.0\.1/).to_timeout
          response = request.perform
          expect(response).to include 'gateway_response'
          expect(response['gateway_response']).to include 'error'
          expect(response['gateway_response']['error']).to include 'code', 'description'
          expect(response['gateway_response']['error']['code']).to eq '-1'
        end
      end

      context 'when response signature is incorrect' do
        let(:request) do
          BankClient::Request.new(
            target: 'giftdeposit_agent_kass',
            operation: 'pay',
            idcard: '9000240319923',
            amount: 100.0
          )
        end

        before do
          BankClient.configure do |config|
            config.public_key = 'spec/fixtures/wrong_public.key'
          end
        end

        it 'returns correct error' do
          VCR.use_cassette('request/perform_pay_success') do
            response = request.perform
            expect(response).to include 'gateway_response'
            expect(response['gateway_response']).to include 'error'
            expect(response['gateway_response']['error']).to include 'code', 'description'
            expect(response['gateway_response']['error']['code']).to eq '-666'
          end
        end
      end
    end
  end
end
