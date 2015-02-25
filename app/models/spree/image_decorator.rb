#Makes image part db specific
module Spree
  Image.class_eval do
    cattr_accessor :tenant_proc, instance_writer: false, instance_reader: false
    self.tenant_proc = -> { Apartment::Tenant.current_tenant }

    def tenant
      self.class.tenant_proc.call
    end
  end
end
