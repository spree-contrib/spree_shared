class SpreeShared::TenantInitializer
  attr_reader :db_name

  def initialize(db_name)
    @db_name = db_name
    ENV['RAILS_CACHE_ID'] = db_name
    ENV['AUTO_ACCEPT'] = 'true'
    ENV['SKIP_NAG'] = 'yes'
  end

  def create_database
    ActiveRecord::Base.establish_connection #make sure we're talkin' to db
    ActiveRecord::Base.connection.execute("DROP SCHEMA IF EXISTS #{db_name} CASCADE")
    Apartment::Tenant.create db_name
  end

  def load_seeds
    Apartment::Tenant.process(db_name) do
      Rake::Task["db:seed"].invoke
    end
  end

  def load_spree_sample_data
    Apartment::Tenant.process(db_name) do
      SpreeSample::Engine.load_samples
    end
  end

  def create_admin
    Apartment::Tenant.process(db_name) do
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
  end

  def load_spree_fancy_sample_data
    Apartment::Tenant.process(db_name) do
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
    end
  end

  def fix_sample_payments
    Apartment::Tenant.process(db_name) do   
      # create payments based on the totals since they can't be known in YAML (quantities are random)
      method = Spree::PaymentMethod.where(:name => 'Credit Card', :active => true).first

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
    end
  end

end