namespace :spree_shared do
  desc "Bootstraps single database."
  task :bootstrap, [:db_name] => [:environment] do |t, args|
    if args[:db_name].blank?
      puts %q{You must supply db_name, with "rake spree_shared:bootstrap['the_db_name']"}
    else
      db_name = args[:db_name]

      #convert name to postgres friendly name
      db_name.gsub!('-','_')

      #create the database
      puts "Creating database: #{db_name}"
      ActiveRecord::Base.establish_connection #make sure we're talkin' to db
      ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{db_name} CASCADE")
      Apartment::Tenant.create db_name

      #seed and sample it
      puts "Loading seed & sample data into database: #{db_name}"
      ENV['RAILS_CACHE_ID'] = db_name
      Apartment::Tenant.process(db_name) do
        ENV['AUTO_ACCEPT'] = 'true'
        ENV['SKIP_NAG'] = 'yes'

        Rake::Task["db:seed"].invoke
        Rake::Task["spree_sample:load"].invoke

        store_name = db_name.humanize.titleize

        #Need to manually create admin as it's not created by default in production mode
        if Rails.env.production?
          password =  "spree123"
          email =  "spree@example.com"

          unless Spree::User.find_by_email(email)
            admin = Spree::User.create(:password => password,
                                :password_confirmation => password,
                                :email => email,
                                :login => email)
            role = Spree::Role.find_or_create_by_name "admin"
            admin.roles << role
            admin.save
          end
        end

        # load some extra sample data for spree_fancy
        tags      = Spree::Taxonomy.create(:name => 'Tags')
        slider    = Spree::Taxon.create({:taxonomy_id => tags.id, :name => 'Slider'})
        featured  = Spree::Taxon.create({:taxonomy_id => tags.id, :name => 'Featured'})
        latest    = Spree::Taxon.create({:taxonomy_id => tags.id, :name => 'Latest'})

        products = Spree::Product.all
        products[0..6].each do |product|
          product.taxons << slider
        end
        products[4..16].each do |product|
          product.taxons << featured
        end
        products[0..12].each do |product|
          product.taxons << latest
        end


        # create payments based on the totals since they can't be known in YAML (quantities are random)
        method = Spree::PaymentMethod.where(:name => 'Credit Card', :active => true, :environment => 'production').first

        # Hack the current method so we're able to return a gateway without a RAILS_ENV
        Spree::Gateway.class_eval do
          def self.current
            Spree::Gateway::Bogus.new
          end
        end

        # This table was previously called spree_creditcards, and older migrations
        # reference it as such. Make it explicit here that this table has been renamed.
        Spree::CreditCard.table_name = 'spree_credit_cards'

        creditcard = Spree::CreditCard.create(:cc_type => 'visa', :month => 12, :year => Time.now.year, :last_digits => '1111',
                                                :name => 'Sean Schofield',
                                                :gateway_customer_profile_id => 'BGS-1234')
        Spree::Order.all.each_with_index do |order, index|
          order.update!
          order.payments.delete_all
          payment = order.payments.create!(:amount => order.total, :source => creditcard.clone, :payment_method => method)
          payment.update_columns({
            :state => 'pending',
            :response_code => '12345'
          })
        end

        puts "Bootstrap completed successfully"

      end
    end

  end

end
