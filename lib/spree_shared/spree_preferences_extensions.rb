# Ugly hack until perferences is extracted to it's own gem
module Spree
  module Preferences

  end
end

require Spree::Core::Engine.root.join "app/models/spree/preferences/preferable"
require Spree::Core::Engine.root.join "app/models/spree/preferences/preferable_class_methods"
require Spree::Core::Engine.root.join "app/models/spree/preferences/configuration"
require Spree::Core::Engine.root.join "app/models/spree/preferences/store"
require Spree::Core::Engine.root.join "app/models/spree/preference"


Spree::Preferences::Configuration.module_eval do
  def preference_cache_key(name)
    [Apartment::Database.current_tenant, self.class.name, name].compact.join('::').underscore
  end
end

Spree::Preferences::Preferable.module_eval do
  def preference_cache_key(name)
    [Apartment::Database.current_tenant, self.class.name, name, (try(:id) || :new)].compact.join('::').underscore
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

      unless @loaded_from.include? Apartment::Database.current_tenant
        Spree::Preference.all.each do |p|
           @cache.write(p.key, p.value)
        end
        @loaded_from << Apartment::Database.current_tenant
      end
    end
end
