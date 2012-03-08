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

  s.add_dependency 'spree_core', '>= 1.0.0'
  # s.add_dependency 'apartment', '>= 0.13.0' #turn back on once apartment offically supports rails 3.1.x
  s.add_development_dependency 'rspec-rails'
end

