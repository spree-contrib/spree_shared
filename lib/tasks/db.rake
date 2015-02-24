namespace :spree_shared do
  desc "Bootstraps single database."
  task :bootstrap, [:db_name] => [:environment] do |t, args|
    if args[:db_name].blank?
      puts %q{You must supply db_name, with "rake spree_shared:bootstrap['the_db_name']"}
    else
      db_name = args[:db_name]

      #convert name to postgres friendly name
      db_name.gsub!('-','_')

      initializer = SpreeShared::TenantInitializer.new(db_name)
      puts "Creating database: #{db_name}"
      initializer.create_database
      puts "Loading seeds & sample data into database: #{db_name}"
      initializer.load_seeds
      initializer.load_spree_sample_data
      # Need to manually create admin as it's not created by default in production mode
      if Rails.env.production?
        initializer.create_admin
      end
      # load some extra sample data for spree_fancy
      initializer.load_spree_fancy_sample_data

      initializer.fix_sample_payments

      puts "Bootstrap completed successfully"
    end

  end

end
