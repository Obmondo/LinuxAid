# frozen_string_literal: true

require_relative '../../../puppet_x/gitlab/runner'

# A function that unregisters a Gitlab runner from a Gitlab instance. Be careful, this will be triggered on noop runs as well!
Puppet::Functions.create_function(:'gitlab_ci_runner::unregister') do
  # @summary A function that unregisters a Gitlab runner from a Gitlab instance. Be careful, this will be triggered on noop runs as well!
  # @param url The url to your Gitlab instance. Please only provide the host part (e.g https://gitlab.com)
  # @param token Runners authentication token.
  # @param ca_file An absolute path to a trusted certificate authority file.
  # @return [Struct[{ id => Integer[1], token => String[1], }]] Returns a hash with the runner id and authentcation token
  # @example Using it as a replacement for the Bolt 'unregister_runner' task
  #   puppet apply -e "notice(gitlab_ci_runner::unregister('https://gitlab.com', 'runner-auth-token'))"
  #
  dispatch :unregister do
    param 'Stdlib::HTTPUrl', :url
    param 'String[1]', :token
    optional_param 'Optional[Stdlib::Unixpath]', :ca_file
    return_type "Struct[{ status => Enum['success'], }]"
  end

  def unregister(url, token, ca_file = nil)
    PuppetX::Gitlab::Runner.unregister(url, { 'token' => token }, ca_file: ca_file)
    { 'status' => 'success' }
  rescue Net::HTTPError => e
    raise "Gitlab runner failed to unregister: #{e.message}"
  end
end
