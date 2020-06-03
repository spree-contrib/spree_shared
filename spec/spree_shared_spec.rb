require 'spec_helper'

require 'apartment/elevators/subdomain'

describe SpreeShared do
  include ActionDispatch::TestProcess

  let(:app) { ->(env) { [200, env, "app"] } }

  let(:middleware) do
    Apartment::Elevators::Subdomain.new(app)
  end

  let(:prepare_db) do
    begin
      Apartment::Tenant.switch!("tenant271")
    rescue Apartment::TenantNotFound
      puts "creating database tenant271"
      Apartment::Tenant.create("tenant271")
      retry
    end
    
    Apartment::Tenant.switch!
  end

  before { prepare_db }

  describe 'change tenant by subdomain' do
    it 'uses another database' do
      expect(Apartment::Tenant.current).to eq('spree_test')
      expect(Apartment::Tenant).to receive(:switch).with('tenant271').and_return([200, nil])
      code, env = middleware.call env_for('http://tenant271.example.com/')
      expect(code).to eq(200)
    end
  end

  describe 'preferences' do
    it 'does not interfere' do
      Spree::Config.logo = "logo/spree_51.png"
      Apartment::Tenant.switch!("tenant271")
      expect(Spree::Config.logo).to eq("logo/spree_50.png")
      Apartment::Tenant.switch!
      expect(Spree::Config.logo).to eq("logo/spree_51.png")
    end
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
