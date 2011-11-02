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

        t = Spraycan::Theme.create(:name => 'Default Theme', :active => true)
        t.view_overrides.create(:name => 'add_to_products_list_item', :virtual_path => 'shared/_products',
                                :replace_with => 'text', :target => 'insert_top',
                                :selector => "[data-hook='products_list_item'], #products_list_item[data-hook]",
                                :replacement => "<b>#{store_name}</b><br>")


        t.view_overrides.create(:name => 'before_products', :virtual_path => 'shared/_products',
                                :replace_with => 'text', :target => 'insert_before',
                                :selector => "[data-hook='products'], #products[data-hook]",
                                :replacement => "<h2>#{store_name} is awesome!</h2>")

        t.view_overrides.create(:name => 'before_taxonomies', :virtual_path => 'shared/_taxonomies',
                                :replace_with => 'text', :target => 'insert_before',
                                :selector => "[data-hook='taxonomies'], #taxonomies[data-hook]",
                                :replacement => "<p>#{store_name} for the best prices!</p>")

        t.view_overrides.create(:name => 'after_home-link', :virtual_path => 'shared/_store_menu',
                                :replace_with => 'text', :target => 'insert_after',
                                :selector => "[data-hook='home-link'], #home-link[data-hook]",
                                :replacement => "<li><a href='#'>#{store_name}</a></li>")

        t.view_overrides.create(:name => 'replace_logo', :virtual_path => 'layouts/spree_application',
                                :replace_with => 'text', :target => 'replace_contents',
                                :selector => "[data-hook='logo'], #logo[data-hook]",
                                :replacement => "<h1 style='color:red;'>#{store_name}</h1>")

        t.view_overrides.create(:name => 'add_to_footer', :virtual_path => 'layouts/spree_application',
                                :replace_with => 'text', :target => 'insert_bottom',
                                :selector => "[data-hook='footer'], #footer[data-hook]",
                                :replacement => "<p>Please call again to #{store_name}</p>")



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

      end
    end

  end

end
