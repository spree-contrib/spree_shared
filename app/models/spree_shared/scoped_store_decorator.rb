module SpreeShared::ScopedStoreDecorator
  private
    # hack hack hack ..
    # aka ENV['RAILS_CACHE_ID'] on a Spree default install
    def rails_cache_id
      Apartment::Tenant.current
    end
end

Spree::Preferences::ScopedStore.prepend(SpreeShared::ScopedStoreDecorator)