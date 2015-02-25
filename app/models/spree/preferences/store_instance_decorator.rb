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