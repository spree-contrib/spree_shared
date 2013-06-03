module Spree
  class Store < ActiveRecord::Base
    # attr_accessible :title, :body
    def create_schema
      Apartment::Database.create(subdomain)
    end
  end
end
