ActionView::Template.class_eval do
  # alias_method :method_name_without_spree_shared, :method_name_without_deface

  # # replaces method already replaced by Deface and
  # # injects database name into method_name to make it multi-tenant aware
  # def method_name_without_deface
  #   "#{ENV['RAILS_CACHE_ID'].gsub('-','_')}_#{method_name_without_spree_shared}"
  # end
end
