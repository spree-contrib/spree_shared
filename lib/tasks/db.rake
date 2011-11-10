namespace :spree_shared do
  desc "Bootstraps single database."
  task :bootstrap, [:db_name] => [:environment] do |t, args|
    if args[:db_name].blank?
      puts %q{You must supply db_name, with "rake spree_shared:bootstrap['the_db_name']"}
    else
      db_name = args[:db_name]

      #create the database
      puts "Creating database: #{db_name}"
      Apartment::Database.create db_name

      #seed and sample it
      puts "Loading seed & sample data into database: #{db_name}"
      Apartment::Database.process(db_name) do
        Image.change_paths db_name

        ENV['AUTO_ACCEPT'] = 'true'
        ENV['SKIP_NAG'] = 'yes'

        Rake::Task["db:seed"].invoke 
        Rake::Task["spree_sample:load"].invoke 

        MailMethod.create(:environment => "production", :active => false)
        pm = PaymentMethod.create(:name => "Credit Card", :environment => "production")
        pm.type = "Gateway::Bogus"
        pm.save

        store_name = db_name.humanize.titleize
        Spree::Config.set :site_name => store_name


        #Need to manually create admin as it's not created by default in production mode
        if Rails.env.production?
          password =  "spree123"
          email =  "spree@example.com"

          unless User.find_by_email(email)
            admin = User.create(:password => password,
                                :password_confirmation => password,
                                :email => email,
                                :login => email)
            role = Role.find_or_create_by_name "admin"
            admin.roles << role
            admin.save
          end
        end

        puts "Bootstrap completed successfully"

      end
    end

  end

end
