# frozen_string_literal: true

require_relative '../../../puppet_x/gitlab/runner'

# A function that registers a Gitlab runner on a Gitlab instance. Be careful, this will be triggered on noop runs as well!
Puppet::Functions.create_function(:'gitlab_ci_runner::register') do
  # @param url The url to your Gitlab instance. Please only provide the host part (e.g https://gitlab.com)
  # @param token Registration token.
  # @param additional_options A hash with all additional configuration options for that runner
  # @param ca_file An absolute path to a trusted certificate authority file.
  # @return [Struct[{ id => Integer[1], token => String[1], }]] Returns a hash with the runner id and authentcation token
  # @example Using it as a replacement for the Bolt 'register_runner' task
  #   puppet apply -e "notice(gitlab_ci_runner::register('https://gitlab.com', 'registration-token'))"
  #
  dispatch :register do
    param 'Stdlib::HTTPUrl', :url
    param 'String[1]', :token
    optional_param 'Gitlab_ci_runner::Register', :additional_options
    optional_param 'Optional[Stdlib::Unixpath]', :ca_file
    return_type 'Struct[{ id => Integer[1], token => String[1], }]'
  end

  def register(url, token, additional_options = {}, ca_file = nil)
    PuppetX::Gitlab::Runner.register(url, additional_options.merge('token' => token), ca_file: ca_file)
  rescue Net::HTTPError => e
    raise "Gitlab runner failed to register: #{e.message}"
  end
end
