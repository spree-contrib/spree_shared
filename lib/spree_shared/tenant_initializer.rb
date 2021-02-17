class SpreeShared::TenantInitializer
  attr_reader :db_name

  def initialize(db_name)
    @db_name = db_name
    ENV['AUTO_ACCEPT'] = 'true'
    ENV['SKIP_NAG'] = 'yes'
  end

  def create_database
    ActiveRecord::Base.establish_connection #make sure we're talkin' to db
    drop_tenant_if_exists
    Apartment::Tenant.create db_name
  end

  def drop_tenant_if_exists
    Apartment::Tenant.drop db_name
  rescue Apartment::TenantNotFound
  end

  def load_seeds
    Apartment::Tenant.switch(db_name) do
      Rails.application.load_seed
    end
  end

  def load_spree_sample_data
    Apartment::Tenant.switch(db_name) do
      SpreeSample::Engine.load_samples
    end
  end

  def create_admin
    Apartment::Tenant.switch(db_name) do
      email = ENV[db_name.upcase+'_ADMIN_EMAIL'] || ENV['ADMIN_EMAIL'] || "spree@example.com"
      password = ENV[db_name.upcase+'_ADMIN_PASSWORD'] || ENV['ADMIN_PASSWORD'] || "spree123"

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

end
