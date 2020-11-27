# frozen_string_literal: true

require 'spec_helper'

require 'apartment/elevators/subdomain'

describe SpreeShared do
  include ActionDispatch::TestProcess

  let(:app) { ->(env) { [200, env, 'app'] } }

  let(:middleware) do
    Apartment::Elevators::Subdomain.new(app)
  end

  let(:prepare_db) do
    begin
      Apartment::Tenant.switch!('tenant271')
    rescue Apartment::TenantNotFound
      puts 'creating database tenant271'
      Apartment::Tenant.create('tenant271')
      retry
    end

    Apartment::Tenant.switch!
    Spree::Preferences::Store.instance.persistence = true
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
    let(:clear_preferences) do
      Apartment::Tenant.switch { Spree::Preference.destroy_all }
      Apartment::Tenant.switch('tenant271') { Spree::Preference.destroy_all }
    end

    shared_examples 'preferences changing' do
      it 'preferences do not interfere between tenants' do
        Spree::Config.logo = 'logo/spree_51.png'
        Apartment::Tenant.switch!('tenant271')
        expect(Spree::Config.logo).to eq('logo/spree_50.png')
        Apartment::Tenant.switch!
        expect(Spree::Config.logo).to eq('logo/spree_51.png')
      end
    end

    context 'When cache is enabled' do
      let(:memory_store) do
        ActiveSupport::Cache.lookup_store(
          :memory_store,
          { namespace: -> { Apartment::Tenant.current } }
        )
      end

      before do
        store = Spree::Preferences::Store.instance
        store.instance_variable_set(:@cache, memory_store)
        clear_preferences
      end

      it_behaves_like 'preferences changing'
    end

    context 'When cache is disabled' do
      let(:null_store) do
        ActiveSupport::Cache.lookup_store(:null_store)
      end

      before do
        store = Spree::Preferences::Store.instance
        store.instance_variable_set(:@cache, null_store)
        clear_preferences
      end

      it_behaves_like 'preferences changing'
    end
  end

  describe 'each_blocks' do
    it 'rescues when there is no Tenant' do
      Apartment.tenant_names = ['tenant_without_db']

      expect { Apartment::Tenant.each_with_default }.to_not raise_error
    end

    it 'iterates over tenants' do
      expected_tenants = ['tenant271']
      Apartment.tenant_names = expected_tenants

      tenants = []
      tenants = Apartment::Tenant.each do |name|
        tenants << name
      end

      expect(Set.new(tenants)).to eq(Set.new(expected_tenants))
    end
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
