require 'spec_helper'
require 'pry'

module Spree
  describe 'Preferences' do
    before do
      Apartment::Database.create("one")
    end

    it "saves preferences to the database with a prefix" do
      Spree::Shared.switch("one")
      Spree::Config[:site_name] = "The One"
      expect(Spree::Config[:site_name].should == "The One"

      Spree::Shared.reset
      Spree::Config[:site_name].should == "Spree Demo Site"
    end
  end
end