require 'spec_helper'
require 'apartment/elevators/subdomain'

describe SpreeShared do
  include ActionDispatch::TestProcess

  let(:app) { ->(env) { [200, env, "app"] } }

  let :middleware do
    Apartment::Elevators::Subdomain.new(app)
  end

  let (:prepare_db) do
    begin
      Apartment::Tenant.switch("tenant271")
    rescue Apartment::DatabaseNotFound
      puts "creating database tenant271"
      Apartment::Tenant.create("tenant271")
      retry
    end
    Apartment::Tenant.switch
  end

  before { prepare_db }

  describe 'change tenant by subdomain' do
    it 'uses another database' do
      expect(Apartment::Tenant.current_tenant).to eq('spree_test')
      code, env = middleware.call env_for('http://tenant271.example.com/')
      expect(code).to eq(200)
      expect(Apartment::Tenant.current_tenant).to eq('tenant271')
    end
  end

  describe 'change image path' do
    before do
      Paperclip.interpolates :tenant do |attachment, style|
        attachment.instance.tenant
      end
      Spree::Image.attachment_definitions[:attachment][:url] = "/spree/products/:tenant/:id/:style/:basename.:extension"
      Spree::Image.attachment_definitions[:attachment][:path] = ":rails_root/public/spree/products/:tenant/:id/:style/:basename.:extension"

      SpreeShared::Engine.activate
      Apartment::Tenant.switch("tenant271")

      self.class.fixture_path = nil # otherwise fixture_file_upload will duplicate current path
    end

    it 'uses current tenant' do
      img =  Spree::Image.new
      img.attachment  = fixture_file_upload(File.expand_path("../fixtures/test_img.jpeg",  __FILE__), 'image/test_img')
      expect(img.attachment.url(:original)).to start_with "/spree/products/tenant271//original/test_img.jpeg?"
    end
  end

  describe 'preferences' do
    it 'does not interfere' do
      Spree::Config.logo = "logo/spree_51.png"
      Apartment::Tenant.switch("tenant271")
      expect(Spree::Config.logo).to eq("logo/spree_50.png")
      Apartment::Tenant.switch
      expect(Spree::Config.logo).to eq("logo/spree_51.png")
    end
  end

  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end
