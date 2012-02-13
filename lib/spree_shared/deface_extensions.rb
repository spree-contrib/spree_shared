Deface::Override.class_eval do

    private
      # check if method is compiled for the current virtual path
      #
      def expire_compiled_template
        #TWEAKED to check for store name added to method name by action_view_extensions.rb
        #
        if compiled_method_name = ActionView::CompiledTemplates.instance_methods.detect { |name| name =~ /^_[a-f0-9]{32}_#{ENV['RAILS_CACHE_ID'].gsub('-','_')}_.*#{args[:virtual_path].gsub(/[^a-z_]/, '_')}/ }
          #if the compiled method does not contain the current deface digest
          #then remove the old method - this will allow the template to be 
          #recompiled the next time it is rendered (showing the latest changes)
          #
          unless compiled_method_name =~ /\A_#{self.class.digest(:virtual_path => @args[:virtual_path])}_/
            ActionView::CompiledTemplates.send :remove_method, compiled_method_name
          end
        end

      end


end
