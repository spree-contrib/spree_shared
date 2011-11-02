Spree Shared
============

Multiple stores using a single Spree application instance.

Uses request subdomain to swap database, view paths, Rails cache (preferences), mail settings, image paths and so much more.

Installation
============

1. Tweak `config/database.yml` to use MySQL, and dummy master database.

2. Add the following line to host `applicaiton.rb` 

    config.middleware.use 'Apartment::Elevators::Subdomain'

3. Create an initializer `config/apartment.rb` with the following:

    Apartment.configure do |config|
      config.prepend_environment = false
      config.database_names = ['store1'] #ahh do we need this?
    end

4. Set namespace for cache engine in `development.rb` and/or `production.rb`

    config.cache_store = :memory_store, { :namespace => lambda { ENV['RAILS_CACHE_ID'] } }



Testing
-------

Be sure to add the rspec-rails gem to your Gemfile and then create a dummy test app for the specs to run against.

    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2011 [name of extension creator], released under the New BSD License
