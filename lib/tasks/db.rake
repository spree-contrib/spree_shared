namespace :spree_shared do
  desc "Bootstraps single database."
  task :bootstrap, [:db_name] => [:environment] do |t, args|
    if args[:db_name].blank?
      puts %q{You must supply db_name, with "rake spree_shared:bootstrap['the_db_name']"}
    else
      db_name = args[:db_name]

      #create the database
      puts "Creating database: #{db_name}"
      ActiveRecord::Base.establish_connection #make sure we're talkin' to db
      ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{db_name} CASCADE")
      Apartment::Database.create db_name

      #seed and sample it
      puts "Loading seed & sample data into database: #{db_name}"
      ENV['RAILS_CACHE_ID'] = db_name 
      Apartment::Database.process(db_name) do
        Spree::Image.change_paths db_name

        ENV['AUTO_ACCEPT'] = 'true'
        ENV['SKIP_NAG'] = 'yes'

        Rake::Task["db:seed"].invoke 
        Rake::Task["spree_sample:load"].invoke 

        mm = Spree::MailMethod.create(:environment => "production")
        mm.active = false
        mm.save!

        pm = Spree::PaymentMethod.create(:name => "Credit Card", :environment => "production")
        pm.type = "Spree::Gateway::Bogus"
        pm.save

        store_name = db_name.humanize.titleize
        Spree::Config.set :site_name => store_name

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

        puts "Bootstrap completed successfully"

      end
    end

  end

end
