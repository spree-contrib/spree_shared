# Ugly hack until perferences is extracted to it's own gem
module Spree
  module Preferences
  end
end

require Spree::Core::Engine.root.join "app/models/spree/preferences/preferable"
require Spree::Core::Engine.root.join "app/models/spree/preferences/preferable_class_methods"
require Spree::Core::Engine.root.join "app/models/spree/preferences/configuration"
require Spree::Core::Engine.root.join "app/models/spree/preferences/store"

require Spree::Core::Engine.root.join "app/models/spree/base"
require Spree::Core::Engine.root.join "app/models/spree/preference"
require Spree::Core::Engine.root.join "app/models/spree/preferences/scoped_store"

Spree::Preferences::ScopedStore.class_eval do
  private
    # hack hack hack ..
    # aka ENV['RAILS_CACHE_ID'] on a Spree default install
    def rails_cache_id
      Apartment::Tenant.current_tenant
    end
end

Spree::Preferences::StoreInstance.class_eval do
  alias_method :exist_without_spree_shared?, :exist?

  def exist?(key)
    load_preferences
    exist_without_spree_shared? key
  end

  private

    def load_preferences
      return unless should_persist?
      @loaded_from ||= []

      unless @loaded_from.include? Apartment::Tenant.current_tenant
        Spree::Preference.all.each do |p|
           @cache.write(p.key, p.value)
        end
        @loaded_from << Apartment::Tenant.current_tenant
      end
    end
end
