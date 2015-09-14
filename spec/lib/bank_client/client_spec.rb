describe BankClient::Client do
  subject { BankClient::Client.new }

  describe '#check' do
    context 'when card number is correct' do
      before do
        allow_any_instance_of(BankClient::Request).to receive(:perform).and_return(
          'gateway_response' => {
            'cardnumber' => '1234567',
            'amount' => '100',
            'comm' => '0'
          }
        )
      end

      it 'calls Request' do
        expect(BankClient::Request).to receive(:new).with(
          target: BankClient::Client::TARGET,
          operation: 'check',
          idcard: '9000240319923'
        ).and_call_original
        result = subject.check(card_id: '9000240319923')
      end

      it 'returns card info' do
        result = subject.check(card_id: '9000240319923')
        expect(result[:status]).to eq true
        expect(result.keys).to include *%i(card_number amount commission)
      end
    end

    context 'when card number is not correct' do
      before do
        allow_any_instance_of(BankClient::Request).to receive(:perform).and_return(
          'gateway_response' => {
            'error' => {
              'code' => -999,
              'description' => 'Карта не найдена'
            }
          }
        )
      end

      it 'returns error' do
        result = subject.check(card_id: '1234567890')
        expect(result[:status]).to eq false
        expect(result.keys).to include *%i(code message)
      end
    end
  end

  describe '#pay' do
    context 'when all parameters are correct' do
      before do
        allow_any_instance_of(BankClient::Request).to receive(:perform).and_return(
          'gateway_response' => {
            'container' => {
              'amount' => '100',
              'authcode' => '31337',
              'card' => '1234567890',
              'comm' => '0',
              'dateoper' => Time.now.iso8601,
              'expiry' => 'never',
              'idlog' => '31337'
            }
          }
        )
      end

      it 'calls Request' do
        expect(BankClient::Request).to receive(:new).with(
          target: BankClient::Client::TARGET,
          operation: 'pay',
          idcard: '9000240319923',
          amount: 100,
          transaction_id: '12345'
        ).and_call_original
        result = subject.pay(card_id: '9000240319923', amount: 100, transaction_id: '12345')
      end

      it 'returns pay result' do
        result = subject.pay(card_id: '9000240319923', amount: 100, transaction_id: '12345')
        expect(result[:status]).to eq true
        expect(result.keys).to include *%i(amount auth_code card_number commission date expiry id_log)
      end
    end

    context 'when some parameter is not correct' do
      before do
        allow_any_instance_of(BankClient::Request).to receive(:perform).and_return(
          'gateway_response' => {
            'container' => {
              'error' => {
                'code' => -999,
                'description' => 'Карта не найдена'
              }
            }
          }
        )
      end

      it 'returns error' do
        result = subject.pay(card_id: '1234567890', amount: 100, transaction_id: '12345')
        expect(result[:status]).to eq false
        expect(result.keys).to include *%i(code message)
      end
    end
  end
end
