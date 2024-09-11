# More info at https://github.com/guard/guard#readme
directories %w(lib test spec manifests) \
  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

guard 'rake', :task => 'test' do
  watch(%r{^manifests\/(.+)\.pp$})
  watch(%r{^spec\/(.+)\.rb$})
end

#### tmux 1.7+ can send rspec results to the TMUX status pane.
notification( :tmux, {
  display_message: true,
  timeout: 5, # in seconds
  default_message_format: '%s >> %s',
  # the first %s will show the title, the second the message
  # Alternately you can also configure *success_message_format*,
  # *pending_message_format*, *failed_message_format*
  line_separator: ' > ', # since we are single line we need a separator
  color_location: 'status-left-bg', # to customize which tmux element will change color

  # Other options:
  default_message_color: 'black',
  success: 'colour150',
  failure: 'colour174',
  pending: 'colour179',
  # Notify on all tmux clients

  display_on_all_clients: false
}) if ( ENV.fetch( 'TMUX', false ) && (%x{tmux -V}.split(' ').last.split('.').last.to_i > 6 ))
# vim:set syntax=ruby:

