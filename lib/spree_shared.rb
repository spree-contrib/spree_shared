require 'spree_core'
require 'apartment'
require 'spree_shared/engine'
require 'spree_shared/switcher'
require 'spree_shared/spree_preferences_extensions'

module Spree
  module Shared
    def self.switch(subdomain)
      Apartment::Database.switch(subdomain)
      ENV['RAILS_CACHE_ID'] = subdomain
    end

    def self.reset
      Apartment::Database.reset
      ENV['RAILS_CACHE_ID'] = nil
    end
  end
end
