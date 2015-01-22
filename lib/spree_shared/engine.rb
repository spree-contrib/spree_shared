module SpreeShared
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_shared'

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(%W(#{config.root}/app/**/*_decorator*.rb)) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
