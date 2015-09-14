require 'openssl'
require 'httparty'
require 'gyoku'
require 'base64'
require 'logger'
require 'nokogiri'
require 'nori'
require 'hex_string'
require 'ostruct'

# Interacts with the bank's gateway and processes responses.
# Each request body and response body is signed with RSA-SHA1.
#
# There are only 2 operations:
# check:: get card balance
# pay:: deposit money to the card
#
# = Examples
#
#  BankClient.check(card_number: '123123123')
#  # => { status: true, card_number: '123123123', amount: 100.0, commission: 1.0 }
#
#  BankClient.pay(card_number: '123123123', amount: 100.0)
#  # =>
#  # {
#  #   status: true,
#  #   amount: 100.0,
#  #   auth_code: '330854',
#  #   card_number: '123123123',
#  #   commission: 1.0,
#  #   date: '20.11.2015 06:21:49',
#  #   expiry: '0817',
#  #   id_log: '6e687a4f-b25c-4ed4-a10e-16574519bbed'
#  # }
module BankClient
  class SignatureNotValid < StandardError; end

  class Configuration
    attr_accessor :auth_login, :auth_pass, :private_key, :public_key, :url, :logger

    def initialize
      @url = 'https://127.0.0.1'
      @private_key = nil
      @public_key = nil
      @auth_login = 'auth_login'
      @auth_pass = 'auth_pass'
      @logger = nil
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration if block_given?
    end
  end
end

require 'bank_client/version'
require 'bank_client/signature'
require 'bank_client/request'
require 'bank_client/client'
