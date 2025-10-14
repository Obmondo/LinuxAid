# frozen_string_literal: true

require_relative '../../../puppet_x/gitlab/runner'

# A function that unregisters a Gitlab runner from a Gitlab instance, if the local token is there.
# This is meant to be used in conjunction with the gitlab_ci_runner::register_to_file function.
Puppet::Functions.create_function(:'gitlab_ci_runner::unregister_from_file') do
  # @param url The url to your Gitlab instance. Please only provide the host part (e.g https://gitlab.com)
  # @param runner_name The name of the runner. Use as identifier for the retrived auth token.
  # @param proxy HTTP proxy to use when unregistering
  # @param ca_file An absolute path to a trusted certificate authority file.
  # @example Using it as a Deferred function with a file resource
  #   file { '/etc/gitlab-runner/auth-token-testrunner':
  #     file    => absent,
  #     content => Deferred('gitlab_ci_runner::unregister_from_file', ['http://gitlab.example.org'])
  #   }
  #
  dispatch :unregister_from_file do
    # We use only core data types because others aren't synced to the agent.
    param 'String[1]', :url
    param 'String[1]', :runner_name
    optional_param 'Optional[String[1]]', :proxy
    optional_param 'Optional[String[1]]', :ca_file # This function will be deferred so can't use types from stdlib etc.
  end

  def unregister_from_file(url, runner_name, proxy = nil, ca_file = nil)
    filename = "/etc/gitlab-runner/auth-token-#{runner_name}"
    return "#{filename} file doesn't exist" unless File.exist?(filename)

    authtoken = File.read(filename).strip
    if Puppet.settings[:noop]
      message = "Not unregistering gitlab runner #{runner_name} when in noop mode"
      Puppet.debug message
      message
    else
      begin
        if !ca_file.nil? && !File.exist?(ca_file)
          Puppet.warning('Unable to unregister gitlab runner at this time as the specified `ca_file` does not exist. The runner config will be removed from this hosts config only; please remove from gitlab manually.')
          return 'Specified CA file doesn\'t exist, not attempting to create authtoken'
        end
        PuppetX::Gitlab::Runner.unregister(url, { 'token' => authtoken }, proxy, ca_file)
        message = "Successfully unregistered gitlab runner #{runner_name}"
        Puppet.debug message
        message
      rescue Net::HTTPError => e
        # Chances are the runner is already unregistered.  Best to just log a warning message but otherwise exit the function cleanly
        message = "Error whilst unregistering gitlab runner #{runner_name}: #{e.message}"
        Puppet.warning message
        message
      end
    end
  end
end
