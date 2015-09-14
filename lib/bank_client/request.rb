module BankClient
  # This is the core class which implements request to the gateway
  class Request
    include HTTParty

    XML_NS = "http://bank.ru/gateway/request"
    XML_DECLARATION = '<?xml version="1.0" encoding="windows-1251"?>'

    # HTTParty settings
    headers('Content-Type' => 'application/xml', 'User-Agent' => 'API Client')
    default_options.update(verify: false)
    default_timeout 15

    def initialize(target:, operation:, idcard:, amount: nil, transaction_id: nil)
      @data = {
        target: target,
        operation: operation,
        idcard: idcard
      }
      @data[:amount] = amount if !amount.nil?
      @data[:'transaction-id'] = transaction_id if !transaction_id.nil?

      self.class.base_uri BankClient.configuration.url
      self.class.basic_auth BankClient.configuration.auth_login, BankClient.configuration.auth_pass
      self.class.logger BankClient.configuration.logger, :info, :curl
    end

    # Performs request to the server: builds request body, signs the request, attaches signature, and converts to xml
    def perform
      build_request_body
      @response = self.class.post('', body: @request_body)
      verify_response
      process_response
    rescue Timeout::Error, Errno::ETIMEDOUT, Errno::ENETUNREACH, SocketError => e
      {
        'gateway_response' => {
          'error' => {
            'code' => '-1',
            'description' => 'Отсутствует подключение к интернету. Повторите попытку позже'
          }
        }
      }
    end

    private

    def build_request_body
      request_xml = convert_data_to_xml
      signature = sign_request(request_xml)
      wrap_request(signature)
    end

    def convert_data_to_xml
      Gyoku.xml(@data)
    end

    def sign_request(xml)
      BankClient::Signature.sign(xml)
    end

    def wrap_request(signature)
      request_body = {
        gateway: {
          request: @data,
          sig: signature,
          '@xmlns' => XML_NS
        }
      }

      @request_body = "#{XML_DECLARATION}\n#{Gyoku.xml(request_body)}"
    end

    def verify_response
      xml = Nokogiri.XML(@response.body, nil, 'UTF-8')
      container = xml.css('container')
      sig = xml.css('sig')

      unless [container, sig].all?(&:empty?)
        data = container[0].inner_html
        sig = sig[0].content
        begin
          BankClient::Signature.verify(sig, data)
        rescue => e
          @response = signature_error_response
        end
      end

      @response
    end

    def process_response
      @response.parsed_response
    end

    def signature_error_response
      OpenStruct.new(
        parsed_response: {
          'gateway_response' => {
            'error' => {
              'code' => '-666',
              'description' => 'Ошибка верификации подписи ответа сервера'
            }
          }
        }
      )
    end
  end
end
