#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../lib/puppet_x/gitlab/runner'
require_relative '../../ruby_task_helper/files/task_helper'

class UnregisterRunnerTask < TaskHelper
  def task(**kwargs)
    url     = kwargs[:url]
    options = kwargs.reject { |key, _| %i[_task _installdir url].include?(key) }

    begin
      PuppetX::Gitlab::Runner.unregister(url, options)
      { status: 'success' }
    rescue Net::HTTPError => e
      raise TaskHelper::Error.new("Gitlab runner failed to unregister: #{e.message}", 'bolt-plugin/gitlab-ci-runner-unregister-error')
    end
  end
end

UnregisterRunnerTask.run if $PROGRAM_NAME == __FILE__
