Spree::Preferences::ScopedStore.class_eval do
  private
    # hack hack hack ..
    # aka ENV['RAILS_CACHE_ID'] on a Spree default install
    def rails_cache_id
      Apartment::Tenant.current_tenant
    end
end