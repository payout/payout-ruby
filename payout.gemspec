$:.push File.expand_path('../lib', __FILE__)

require 'payout/version'

Gem::Specification.new do |s|
  s.name        = 'payout'
  s.version     = Payout::VERSION
  s.homepage    = 'http://github.com/payout/payout-ruby'
  s.license     = 'BSD'
  s.summary     = 'Payout your customers quickly and easily. See '\
    'www.payout.com for more.'
  s.authors     = ["Robert Honer"]
  s.email       = ['robert@payout.com']
  s.files       = Dir['lib/**/*.rb']

  s.add_dependency 'rest-client', '~> 1.8'
  s.add_development_dependency 'rspec'
end
