Spree Shared
============

Multiple stores using a single Spree application instance.

Uses request subdomain to swap database, Rails cache (preferences), image paths.

Installation
============

1. Make sure your `config/database.yml` has valid db connection.

2. Create an initializer `config/initializers/apartment.rb` with the following command:

````shell
    bundle exec rails generate apartment:install
````

   search for following line:

````ruby
    Apartment.configure do |config|
    ...
      # supply list of database names for migrations to run on
      config.tenant_names = lambda{ ToDo_Tenant_Or_User_Model.pluck :database }
    end
````

   and change it to include two sample subdomains:

````ruby
    Apartment.configure do |config|
      ...
      config.tenant_names = ['store1', 'store2']
    end
````

3. Add the following line to host `applicaiton.rb`

````ruby
    config.middleware.use 'Apartment::Elevators::Subdomain'
````

4. Change file paths and urls by adding to `config/initializers/spree.rb` following:

````ruby
    Spree::Image.attachment_definitions[:attachment][:url] = "/spree/products/:tenant/:id/:style/:basename.:extension"
    Spree::Image.attachment_definitions[:attachment][:path] = ":rails_root/public/spree/products/:tenant/:id/:style/:basename.:extension"
````

   then allow Paperclip to access tenant from Spree::Image by adding following to Spree initializer:

````ruby
    Paperclip.interpolates :tenant do |attachment, style|
      attachment.instance.tenant
    end
````

   By default tenant will resolve to `Apartment::Tenant.current_tenant` but you can change it -
   eg. suppose you use databases like tenant_12345 and only want tenant id in file path,
   then add following line to `config/initializers/apartment.rb`

````ruby
    Spree::Image.tenant_proc = -> { Apartment::Tenant.current_tenant.match(/(\d+)/)[1] }
````

5. Bootstrap sample stores

````bash
    bundle exec rake spree_shared:bootstrap['store1']
    bundle exec rake spree_shared:bootstrap['store2']
````

6. Setup local subdomains for sample stores, as spree_shared uses by default subdomain routing you need to confirm some local domains such as:

store1.spree.dev
store2.spree.dev

This can be done using Pow or editing your local /etc/hosts file.


7. Set namespace for cache engine in `development.rb` and/or `production.rb`

````ruby
    config.cache_store = :memory_store, { :namespace => lambda { Apartment::Tenant.current_tenant } }
````



Testing
-------

From this extension directory just run following commands:

````bash
    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec
````

Copyright (c) 2011 Spree Commerce Inc, released under the New BSD License
