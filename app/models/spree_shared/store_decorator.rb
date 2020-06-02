module SpreeShared::StoreDecorator
  def exist?(key)
    load_preferences
    super
  end

  private

    def load_preferences
      return unless should_persist?
      @loaded_from ||= []

      unless @loaded_from.include? Apartment::Tenant.current
        Spree::Preference.all.each do |p|
           @cache.write(p.key, p.value)
        end
        @loaded_from << Apartment::Tenant.current
      end
    end
end

Spree::Preferences::Store.prepend(SpreeShared::StoreDecorator)