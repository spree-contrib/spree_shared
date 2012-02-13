#Makes image part db specific
module Spree
  Image.class_eval do
    def self.change_paths(database)
      Image.attachment_definitions[:attachment][:path] = ":rails_root/public/spree/#{database}/products/:id/:style/:basename.:extension"
      Image.attachment_definitions[:attachment][:url] = "/spree/#{database}/products/:id/:style/:basename.:extension"
    end
  end
end
