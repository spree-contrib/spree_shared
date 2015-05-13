# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_shared/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_shared'
  s.version     = SpreeShared.version
  s.summary     = 'Adds multi-tenancy to a Spree application.'
  s.description = 'Adds multi-tenancy to a Spree application using the Apartment gem.'
  s.required_ruby_version = '>= 2.1.0'

  s.author            = 'Brian D. Quinn'
  s.email             = 'brian@spreecommerce.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  s.add_runtime_dependency 'spree_core', '~> 3.0'
  s.add_runtime_dependency 'spree_sample', '~> 3.0'
  s.add_runtime_dependency 'apartment', '~> 0.26.1'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry'
end
