# Spree Shared

[![Build Status](https://travis-ci.org/spree-contrib/spree_shared.svg?branch=master)](https://travis-ci.org/spree-contrib/spree_shared)
[![Code Climate](https://codeclimate.com/github/spree-contrib/spree_shared/badges/gpa.svg)](https://codeclimate.com/github/spree-contrib/spree_shared)

Multiple stores using a single Spree application instance.

Uses request subdomain to swap database, Rails cache (preferences), image paths.

---

### Installation

Add to your `Gemfile`:

```ruby
gem 'spree_shared', github: 'spree-contrib/spree_shared', branch: 'master'
```

Make sure your `config/database.yml` has valid db connection.

Create an initializer `config/initializers/apartment.rb` with the following command:

```bash
bundle exec rails generate apartment:install
```

Search for following line:

```ruby
Apartment.configure do |config|
  ...
  # supply list of database names for migrations to run on
  config.tenant_names = lambda { ToDo_Tenant_Or_User_Model.pluck :database }
end
```

And change it to include two sample subdomains:

```ruby
Apartment.configure do |config|
  ...
  config.tenant_names = %w(store1 store2)
end
```

Add the following line to host `application.rb`

```ruby
config.middleware.use 'Apartment::Elevators::Subdomain'
```

Change file paths and urls by adding to `config/initializers/spree.rb` following:

```ruby
Spree::Image.attachment_definitions[:attachment][:url] = '/spree/products/:tenant/:id/:style/:basename.:extension'
Spree::Image.attachment_definitions[:attachment][:path] = ':rails_root/public/spree/products/:tenant/:id/:style/:basename.:extension'
```

Then allow Paperclip to access tenant from Spree::Image by adding following to Spree initializer:

```ruby
Paperclip.interpolates :tenant do |attachment, _style|
  attachment.instance.tenant
end
```

By default tenant will resolve to `Apartment::Tenant.current_tenant` but you can change it - eg. suppose you use databases like tenant_12345 and only want tenant id in file path, then add following line to `config/initializers/apartment.rb`

```ruby
Spree::Image.tenant_proc = -> { Apartment::Tenant.current_tenant.match(/(\d+)/)[1] }
```

Bootstrap sample stores:

```bash
bundle exec rake spree_shared:bootstrap['store1']
bundle exec rake spree_shared:bootstrap['store2']
```

Setup local subdomains for sample stores, as spree_shared uses by default subdomain routing you need to confirm some local domains such as:

    store1.spree.dev
    store2.spree.dev

This can be done using [Pow][4] or editing your local `/etc/hosts` file.

Set namespace for cache engine in `development.rb` and/or `production.rb`

```ruby
config.cache_store = :memory_store, { namespace: lambda { Apartment::Tenant.current_tenant } }
```

### Setting Store Preferences

If you'd like to set preferences for every store you can do so in your `config/initializers/spree.rb` initializer by iterating over each store, and then setting it's preference.  Since this is multi-tenant with each store having their own database the usual Spree.config block can't be used as it only sets the preference for a single database.

Here is an example:

```
Apartment.tenant_names.each do |store|
  begin
    Apartment::Database.switch store
    Spree::Config.auto_capture = true
  rescue
    puts "  Failed to set up config for store '#{store}'"
  end
end
```

---

## Contributing

See corresponding [guidelines][5]

---

Copyright (c) 2013-2015 [Spree Commerce Inc][1], and other [contributors][2], released under the [New BSD License][3]

[1]: https://github.com/spree/spree
[2]: https://github.com/spree-contrib/spree_shared/graphs/contributors
[3]: https://github.com/spree-contrib/spree_shared/blob/master/LICENSE.md
[4]: http://pow.cx
[5]: https://github.com/spree-contrib/spree_shared/blob/master/CONTRIBUTING.md
