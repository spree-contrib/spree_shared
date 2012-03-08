Deface::Override.new(:name => 'replace_layout_scripts',
                     :virtual_path => 'spree/layouts/spree_application',
                     :sequence => {:after => '_spraycan_ui'},
                     :replace => %q{code[erb-loud]:contains('javascript_include_tag "/spraycan/compiled')},
                     :closing_selector => %q{code[erb-loud]:contains('stylesheet_link_tag "/spraycan/compiled')}) do
  %q{<%= javascript_include_tag "/spraycan/#{ENV['RAILS_CACHE_ID']}/compiled/#{Spraycan::Config[:javascript_digest]}" %>
<%= stylesheet_link_tag "/spraycan/#{ENV['RAILS_CACHE_ID']}/compiled/#{Spraycan::Config[:stylesheet_digest]}", :id => 'compiled_stylesheets' %>}
end
