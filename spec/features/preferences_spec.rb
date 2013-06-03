require 'spec_helper'

feature 'Preferences' do
  context "should not be shared across stores" do
    let!(:store_a) { FactoryGirl.create(:store_with_schema) }
    let!(:store_b) { FactoryGirl.create(:store_with_schema) }

    before do
      Spree::Shared.switch(store_a.subdomain)
      Spree::Config[:site_name] = store_a.name

      Spree::Shared.switch(store_b.subdomain)
      Spree::Config[:site_name] = store_b.name

      Apartment::Database.reset
    end

    scenario "correctly shows Store A's name as the title" do
      visit spree.products_url(:subdomain => store_a.subdomain)
      page.title.should == store_a.name
    end

    scenario "correctly shows Store B's name as the title" do
      visit spree.products_url(:subdomain => store_b.subdomain)
      page.title.should == store_b.name
    end
  end
end