module SpreeShared::TenantDecorator
  def each
    Apartment.tenant_names.each do |name|
      Apartment::Tenant.switch(name) do
        yield(name) if block_given?
      end
    rescue Apartment::TenantNotFound
      puts "Failed to connect to tenant '#{name}'"
    end
  end

  def each_with_default(&block)
    default(&block) if block_given?
    each(&block) if block_given?
  end

  private

  def default
    Apartment::Tenant.switch do
      yield(Apartment::Tenant.current) if block_given?
    end
  rescue Apartment::TenantNotFound
    puts "Failed to connect to default tenant"
  end
end

Apartment::Tenant.extend(SpreeShared::TenantDecorator)
