# ⚠️ Deprecation notice ⚠️

Spree supports multi-store scenarios out of the box. The apartment gem, which this gem depends on is not maintained anymore, hence we won't maintain and support this gem anymore.

# Spree Shared

[![Build Status](https://travis-ci.org/spree-contrib/spree_shared.svg?branch=master)](https://travis-ci.org/spree-contrib/spree_shared)
[![Code Climate](https://codeclimate.com/github/spree-contrib/spree_shared/badges/gpa.svg)](https://codeclimate.com/github/spree-contrib/spree_shared)

Multiple stores using a single Spree application instance.

Uses request subdomain to swap database, Rails cache (preferences), image paths.

---

### Installation

1. Add to your `Gemfile`:

    ```ruby
    gem 'spree_shared', github: 'spree-contrib/spree_shared', branch: 'master'
    ```

    Make sure your `config/database.yml` has valid db connection.

2. Create `config/initializers/apartment.rb`with the following command:

    ```bash
    bundle exec rails generate apartment:install
    ```

3. Search for following line inside `config/initializers/apartment.rb`:

    ```ruby
      config.tenant_names = lambda { ToDo_Tenant_Or_User_Model.pluck :database }
    ```

    And change it to include two sample subdomains:

    ```ruby
      config.tenant_names = %w(store1 store2)
    ```

4. Bootstrap sample stores:

    ```bash
    bundle exec rake spree_shared:bootstrap['store1']
    bundle exec rake spree_shared:bootstrap['store2']
    ```

5. Setup local subdomains for sample stores, as spree_shared uses by default subdomain routing you need to confirm some local domains such as:

    `store1.spree.dev`
    `store2.spree.dev`
    
    This can be done using [Pow][4] or editing your local `/etc/hosts` file.

6. Set namespace for cache engine in `development.rb` and/or `production.rb`

    ```ruby
    config.cache_store = :memory_store, { namespace: -> { Apartment::Tenant.current } }
    ```

### Setting Store Preferences

If you'd like to set preferences for every store you can do so in your `config/initializers/spree.rb` initializer by iterating over each store, and then setting it's preference.  Since this is multi-tenant with each store having their own database the usual Spree.config block can't be used as it only sets the preference for a single database.

Here is an example:

```
require 'spree_shared/tenant_decorator'

Apartment::Tenant.each do |tenant_name| # also each_with_default available
  Spree::Config.auto_capture = true
rescue
  puts "  Failed to set up config for store '#{tenant_name}'"
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
