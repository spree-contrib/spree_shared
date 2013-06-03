require 'spec_helper'
require 'pry'

feature 'Products' do
  let!(:store_a) { FactoryGirl.create(:store_with_schema) }
  let!(:store_b) { FactoryGirl.create(:store_with_schema) }

  before do
    Apartment::Database.switch(store_a.subdomain)
    FactoryGirl.create(:product, :name => "Store A's Product")

    Apartment::Database.switch(store_b.subdomain)
    FactoryGirl.create(:product, :name => "Store B's Product")

    Apartment::Database.reset
  end

  scenario "Store A's products are only visible to Store A" do
    binding.pry
    visit spree.products_path(:subdomain => store_a.subdomain)
    page.should have_content("Store A's Product")
    page.should_not have_content("Store B's Product")
  end

  scenario "Store B's products are only visible to Store B" do
    visit spree.products_path(:subdomain => store_b.subdomain)
    page.should have_content("Store B's Product")
    page.should_not have_content("Store A's Product")
  end
end