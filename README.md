# BankClient

This gem implements interaction with one secret bank I worked with. The bank provided prepaid gift cards service, and this gem interacts with the bank's API to check card balance and deposit money. The gem was then integrated in a Rails application, and this allowed my customer application users to work with prepaid gift cards.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bank_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bank_client

## Usage

The main module here is `BankClient::Client`, it wraps arount `BankClient::Request` and provides convinient interface for programmer. Examples:

```ruby
BankClient::Client.check(card_id: 1234567890)
# => { status: true, card_number: 1234567890, amount: 1000.0, commission: 0.0 }
```

```ruby
BankClient::Client.deposit(card_id: 1234567890, amount: 500.0, transaction_id: 1450066506)
# => { status: true, auth_code: 12345, card_number: 1234567890, commission: 2.0, date: '2015-12-14', expiry: '1018', id_log: 137 }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

