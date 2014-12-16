# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_shared'
  s.version     = '0.9.0'
  s.summary     = 'Adds multi-tenancy to a Spree application.'
  s.description = 'Adds multi-tenancy to a Spree application using the Apartment gem.'
  s.required_ruby_version = '>= 1.9.2'

  s.author            = 'Brian D. Quinn'
  s.email             = 'brian@spreecommerce.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  s.add_dependency 'spree_core', '~> 2.3'
  s.add_dependency 'apartment', '~> 0.25.2'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
end
