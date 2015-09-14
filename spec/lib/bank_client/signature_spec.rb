describe BankClient::Signature do
  describe '#sign' do
    it 'returns a signature' do
      signature = BankClient::Signature.new('Test').sign
      expect(signature).to be_a String
      expect(signature.size).not_to eq 0
    end
  end

  describe '#verify' do
    context 'when data is valid' do
      it 'returns true' do
        signature = BankClient::Signature.new('Test').sign
        expect(BankClient::Signature.new('Test').verify(signature)).to eq true
      end
    end

    context 'when data is invalid' do
      it 'raises SignatureNotValid' do
        signature = BankClient::Signature.new('Test').sign
        expect{ BankClient::Signature.new('Fail').verify(signature) }.to raise_error BankClient::SignatureNotValid
      end
    end
  end
end
