# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_shared'
  s.version     = '0.70.1'
  s.summary     = 'Add gem summary here'
  s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'Brian D. Quinn'
  s.email             = 'brian@railsdog.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = false

  s.add_dependency 'spree_core', '~> 2.0.0'
  s.add_dependency 'apartment', '0.21.1'
  s.add_dependency 'pg'
  s.add_development_dependency 'rspec-rails', '2.13.2'
  s.add_development_dependency 'capybara', '2.1.0'
  s.add_development_dependency 'factory_girl', '4.2.0'
  s.add_development_dependency 'ffaker', '1.16.1'
  s.add_development_dependency 'pry'

  s.add_development_dependency 'spree_frontend', '~> 2.0.0'
  s.add_development_dependency 'spree_api', '~> 2.0.0'
end

