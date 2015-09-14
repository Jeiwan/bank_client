module BankClient
  # This class wraps around BankClient::Request to provide better interface for operations
  class Client
    TARGET = 'giftdeposit_agent_kass'

    class << self
      def check(card_id:)
        new().check(card_id: card_id)
      end

      def pay(card_id:, amount:, transaction_id:)
        new().pay(card_id: card_id, amount: amount, transaction_id: transaction_id)
      end
    end

    def inititalize
    end

    def check(card_id:)
      if card_id.nil?
        return {
          status: false,
          code: -666,
          message: 'Неверные параметры операции'
        }
      end

      response = Request.new(target: TARGET, operation: 'check', idcard: card_id).perform
      response = response['gateway_response']

      if response['error'].nil?
        {
          status: true,
          card_number: response['cardnumber'],
          amount: response['amount'],
          commission: response['comm']
        }
      else
        message = case response['error']['code'].to_s
          when /-22|-23|-46|-48/
            'Ошибка активации. Сообщите в тех. поддержку'
          when /-11|-49/
            'Активация карты невозможна. Используйте другую карту'
          else
            response['error']['description']
        end

        {
          status: false,
          code: response['error']['code'],
          message: message
        }
      end
    end

    def pay(card_id:, amount:, transaction_id:)
      if [card_id, amount, transaction_id].any?(&:nil?)
        return {
          status: false,
          code: -666,
          message: 'Неверные параметры операции'
        }
      end

      response = Request.new(
        target: TARGET,
        operation: 'pay',
        idcard: card_id,
        amount: amount,
        transaction_id: transaction_id
      ).perform
      response = response['gateway_response']

      unless response['container'].nil?
        response = response['container']
      end

      if response['error'].nil?
        {
          status: true,
          amount: response['amount'],
          auth_code: response['authcode'],
          card_number: response['card'],
          commission: response['comm'],
          date: response['dateoper'],
          expiry: response['expiry'],
          id_log: response['idlog']
        }
      else
        message = case response['error']['code'].to_s
          when /-22|-23|-30|-43|-46|-48/
            'Ошибка активации. Сообщите в тех. поддержку'
          when /-11|-49/
            'Активация карты невозможна. Используйте другую карту'
          else
            response['error']['description']
        end

        {
          status: false,
          code: response['error']['code'],
          message: message
        }
      end
    end
  end
end
