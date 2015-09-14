module BankClient
  # Implements signing and verifying logic
  class Signature
    class << self
      def sign(data)
        new(data).sign
      end

      def verify(signature, data)
        new(data).verify(signature)
      end
    end

    def initialize(data)
      @data = data
    end

    def sign
      private_key = load_key(BankClient.configuration.private_key)
      signature = private_key.sign(sha1_digest, @data)
      signature.to_hex_string.gsub(/\s/, '')
    end

    def verify(signature)
      public_key = load_key(BankClient.configuration.public_key)
      signature = signature.to_byte_string
      public_key.verify(sha1_digest, signature, @data) || raise(SignatureNotValid)
    end

    private

    def load_key(key_path)
      file = File.read(key_path)
      OpenSSL::PKey::RSA.new(file)
    end

    def sha1_digest
      OpenSSL::Digest::SHA1.new
    end
  end
end
