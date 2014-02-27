Spree Shared
============

Multiple stores using a single Spree application instance.

Uses request subdomain to swap database, view paths, Rails cache (preferences), mail settings, image paths and so much more.

Installation
============

1. Tweak `config/database.yml` to use Postgresql, and dummy master database.

2. Add the following line to host `applicaiton.rb` 

````ruby
    config.middleware.use 'Apartment::Elevators::Subdomain'
````

3. Create an initializer `config/apartment.rb` with the following:

````ruby
    Apartment.configure do |config|
      config.prepend_environment = false
      config.tenant_names = ['store1', 'store2']
    end
````

4. Bootstrap sample stores

````bash
    bundle exec rake spree_shared:bootstrap['store1']
    bundle exec rake spree_shared:bootstrap['store2']
````

5. Setup local subdomains for sample stores, as spree_shared uses by default subdomain routing you need to confirm some local domains such as:

store1.spree.dev
store2.spree.dev

This can be done using Pow or editing your local /etc/hosts file.


6. Set namespace for cache engine in `development.rb` and/or `production.rb`

````ruby
    config.cache_store = :memory_store, { :namespace => lambda { ENV['RAILS_CACHE_ID'] } }
````



Testing
-------

Be sure to add the rspec-rails gem to your Gemfile and then create a dummy test app for the specs to run against.

    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2011 [name of extension creator], released under the New BSD License
