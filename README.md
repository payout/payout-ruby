[![Gem Version](https://badge.fury.io/rb/payout.svg)](https://badge.fury.io/rb/payout) [![Build Status](https://travis-ci.org/payout/payout-ruby.svg?branch=master)](https://travis-ci.org/payout/payout-ruby) [![Code Climate](https://codeclimate.com/github/payout/payout-ruby/badges/gpa.svg)](https://codeclimate.com/github/payout/payout-ruby) [![Test Coverage](https://codeclimate.com/github/payout/payout-ruby/badges/coverage.svg)](https://codeclimate.com/github/payout/payout-ruby/coverage)

# Payout Ruby SDK

The Payout Ruby SDK allows you to more quickly integrate with the [Payout](http://www.payout.com) API.

## Installation

The SDK is available as gem, which you can install like so:

```
gem install payout
```

Alternatively, you can add it to you `Gemfile`.

```ruby
gem 'payout'
```

And then run `bundle install`.

## Configuration

```ruby
Payout.api_url =      ENV['PAYOUT_API_URL']           # Defaults to https://live.payout.com
Payout.api_token =    ENV['PAYOUT_API_TOKEN']         # You can find your credentials at
Payout.api_secret =   ENV['PAYOUT_API_SECRET']        # https://dashboard.payout.com/api
Payout.open_timeout = ENV['PAYOUT_OPEN_TIMEOUT'].to_i # Defaults to 30
Payout.read_timeout = ENV['PAYOUT_READ_TIMEOUT'].to_i # Defaults to 80
```

## Documentation

See http://docs.payout.com for documentation.
