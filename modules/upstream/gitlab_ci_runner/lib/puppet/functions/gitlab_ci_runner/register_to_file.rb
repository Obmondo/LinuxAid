# frozen_string_literal: true

require_relative '../../../puppet_x/gitlab/runner'
require 'fileutils'

# A function that registers a Gitlab runner on a Gitlab instance, if it doesn't already exist,
# _and_ saves the retrieved authentication token to a file. This is helpful for Deferred functions.
Puppet::Functions.create_function(:'gitlab_ci_runner::register_to_file') do
  # @param url The url to your Gitlab instance. Please only provide the host part (e.g https://gitlab.com)
  # @param regtoken Registration token.
  # @param runner_name The name of the runner. Use as identifier for the retrieved auth token.
  # @param additional_options A hash with all additional configuration options for that runner
  # @param proxy The HTTP proxy to use when registering
  # @param ca_file An absolute path to a trusted certificate authority file.
  # @return [String] Returns the authentication token
  # @example Using it as a Deferred function
  #   gitlab_ci_runner::runner { 'testrunner':
  #     config               => {
  #       'url'              => 'https://gitlab.com',
  #       'token'            => Deferred('gitlab_ci_runner::register_runner_to_file', [$config['url'], $config['registration-token'], 'testrunner'])
  #       'executor'         => 'shell',
  #     },
  #   }
  #
  dispatch :register_to_file do
    # We use only core data types because others aren't synced to the agent.
    param 'String[1]', :url
    param 'Variant[String[1], Sensitive[String[1]]]', :regtoken
    param 'String[1]', :runner_name
    optional_param 'Hash', :additional_options
    optional_param 'Optional[String[1]]', :proxy
    optional_param 'Optional[String[1]]', :ca_file # This function will be deferred so can't use types from Stdlib etc.
    return_type 'String[1]'
  end

  def register_to_file(url, regtoken, runner_name, additional_options = {}, proxy = nil, ca_file = nil)
    filename = "/etc/gitlab-runner/auth-token-#{runner_name}"
    if File.exist?(filename)
      authtoken = File.read(filename).strip
    else
      return 'DUMMY-NOOP-TOKEN' if Puppet.settings[:noop]

      begin
        # Confirm the specified ca file exists
        if !ca_file.nil? && !File.exist?(ca_file)
          Puppet.warning('Unable to register gitlab runner at this time as the specified `ca_file` does not exist (yet).  If puppet is managing this file, the next run should complete the registration process.')
          return 'Specified CA file doesn\'t exist, not attempting to create authtoken'
        end

        # If this is a Sensitive value it will be unwrapped, otherwise the String
        # will be returned unmodified.
        regtoken = call_function('unwrap', regtoken)

        authtoken = PuppetX::Gitlab::Runner.register(url, additional_options.merge('token' => regtoken), proxy, ca_file)['token']

        # If this function is used as a Deferred function the Gitlab Runner config dir
        # will not exist on the first run, because the package isn't installed yet.
        dirname = File.dirname(filename)
        unless File.exist?(dirname)
          FileUtils.mkdir_p(File.dirname(filename))
          File.chmod(0o700, dirname)
        end

        File.write(filename, authtoken)
        File.chmod(0o400, filename)
      rescue Net::HTTPError => e
        raise "Gitlab runner failed to register: #{e.message}"
      end
    end

    authtoken
  end
end
