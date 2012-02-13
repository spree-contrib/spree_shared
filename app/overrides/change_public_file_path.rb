Deface::Override.new(:name => 'change_public_file_path',
                     :virtual_path => 'spraycan/boot/tweaker',
                     :replace => "script:contains('public_file_path')") do
  %q{<script type="text/javascript">
  Spraycan.public_file_path = '/spraycan/<%= ENV['RAILS_CACHE_ID'] %>/';
</script>}
end
