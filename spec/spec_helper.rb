ENV['RAILS_ENV'] ||= 'test'

begin
  require File.expand_path('../dummy/config/environment', __FILE__)
rescue LoadError
  puts 'Could not load dummy application. Please ensure you have run `bundle exec rake test_app`'
  exit
end

# switch apartment adapter directory to dummy app
Thread.current[:apartment_adapter].instance_variable_set("@default_dir", File.expand_path("../dummy/db",  __FILE__))

require 'spree_shared'
require 'rspec/rails'
require 'apartment'

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
end

Dir[File.join(File.dirname(__FILE__), '/support/**/*.rb')].each { |file| require file }
