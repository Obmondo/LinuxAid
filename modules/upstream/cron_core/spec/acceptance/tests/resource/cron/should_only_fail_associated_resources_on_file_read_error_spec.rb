require 'spec_helper_acceptance'

RSpec.context 'when Puppet cannot read a crontab file' do
  # This test only makes sense for agents that shipped with PUP-9217's
  # changes, so we do not want to run it on older agents.
  def older_agent?(agent)
    puppet_version = Gem::Version.new(on(agent, puppet('--version')).stdout.chomp)
    minimum_puppet_version = if puppet_version < Gem::Version.new('6.0.0')
                               Gem::Version.new('5.5.9')
                             else
                               Gem::Version.new('6.0.5')
                             end

    puppet_version < minimum_puppet_version
  end

  let(:username) { "pl#{rand(999_999).to_i}" }
  let(:failed_username) { "pl#{rand(999_999).to_i}" }

  before(:each) do
    compatible_agents.each do |agent|
      next if older_agent?(agent)

      step "Create the users on #{agent}" do
        user_present(agent, username)
        user_present(agent, failed_username)
      end
    end
  end

  after(:each) do
    compatible_agents.each do |agent|
      next if older_agent?(agent)

      step "Teardown -- Erase the users on #{agent}" do
        run_cron_on(agent, :remove, username)
        user_absent(agent, username)

        user_absent(agent, failed_username)
      end
    end
  end

  compatible_agents.each do |agent|
    it "should only fail the associated resources on #{agent}" do
      if older_agent?(agent)
        skip('Skipping this test since we are on an older agent that does not have the PUP-9217 changes')
      end

      crontab_exe = nil
      step 'Find the crontab executable' do
        crontab_exe = on(agent, 'which crontab').stdout.chomp
      end

      stub_crontab_bin_dir = nil
      stub_crontab_exe = nil
      step 'Create the stub crontab executable that triggers the read error for the failed user' do
        stub_crontab_bin_dir = agent.tmpdir('stub_crontab_bin_dir')
        stub_crontab_exe = "#{stub_crontab_bin_dir}/crontab"

        # On Linux and OSX, we read a user's crontab by running crontab -u <username>,
        # where the crontab command is run as root. However on AIX/Solaris, we read a
        # user's crontab by running the crontab command as that user. Thus our mock
        # crontab executable needs to check if we're reading our failed user's crontab
        # (Linux and OSX) OR running crontab as our failed user (AIX and Solaris) before
        # triggering the FileReadError
        stub_crontab_exe_script = <<-SCRIPT
#!/usr/bin/env bash
 if [[ "$@" =~ #{failed_username} || "`id`" =~ #{failed_username} ]]; then
  echo "Mocking a FileReadError for the #{failed_username} user's crontab!"
  exit 1
fi
 #{crontab_exe} $@
SCRIPT

        create_remote_file(agent, stub_crontab_exe, stub_crontab_exe_script)
        on(agent, "chmod 777 #{stub_crontab_bin_dir}")
        on(agent, "chmod 777 #{stub_crontab_exe}")
      end

      path_env_var = nil
      step 'Get the value of the PATH environment variable' do
        path_env_var = on(agent, 'echo $PATH').stdout.chomp
      end

      puppet_result = nil
      step 'Add some cron entries with Puppet' do
        # We delete our mock crontab executable here to ensure that Cron[second_entry]'s
        # evaluation fails because of the FileReadError raised in the prefetch
        # step. Otherwise, Cron[second_entry]'s evaluation will fail at the write step
        # because Puppet would still be invoking our mock crontab executable, which would
        # pass the test on an agent that swallows FileReadErrors in the cron provider's
        # prefetch step.
        manifest = [
          cron_manifest('first_entry', command: 'ls', user: username),
          file_manifest(stub_crontab_exe, ensure: :absent),
          cron_manifest('second_entry', command: 'ls', user: failed_username),
        ].join("\n\n")
        manifest_file = agent.tmpfile('crontab_overwrite_manifest')
        create_remote_file(agent, manifest_file, manifest)

        # We need to run a script here instead of a command because:
        #   * We need to cd into a directory that our user can access. Otherwise, bash will
        #   fail to execute stub_crontab_exe on AIX and Solaris because we run crontab
        #   as the given user, and the given user does not have access to Puppet's cwd.
        #
        #   * We also need to pass-in our PATH to Puppet since it contains stub_crontab_bin_dir.
        apply_crontab_overwrite_manifest = agent.tmpfile('apply_crontab_overwrite_manifest')
        script = <<-SCRIPT
  #!/usr/bin/env bash
  cd #{stub_crontab_bin_dir} && puppet apply #{manifest_file}
  SCRIPT
        create_remote_file(agent, apply_crontab_overwrite_manifest, script)
        on(agent, "chmod a+x #{apply_crontab_overwrite_manifest}")

        puppet_result = on(agent, "bash #{apply_crontab_overwrite_manifest}", environment: { PATH: "#{stub_crontab_bin_dir}:#{path_env_var}" })
      end

      step 'Verify that Puppet fails a Cron resource associated with an unreadable crontab file' do
        assert_match(%r{Cron.*second_entry}, puppet_result.stderr, 'Puppet does not fail a Cron resource associated with an unreadable crontab file')
      end

      step 'Verify that Puppet does not fail a Cron resource associated with a readable crontab file' do
        assert_no_match(%r{Cron.*first_entry}, puppet_result.stderr, 'Puppet fails a Cron resource associated with a readable crontab file')
      end

      step 'Verify that Puppet successfully evaluates a Cron resource associated with a readable crontab file' do
        assert_match(%r{Cron.*first_entry}, puppet_result.stdout, 'Puppet fails to evaluate a Cron resource associated with a readable crontab file')
      end

      step 'Verify that Puppet did update the readable crontab file with the Cron resource' do
        assert_matching_arrays(['* * * * * ls'], crontab_entries_of(agent, username), 'Puppet fails to update a readable crontab file with the specified Cron entry')
      end
    end
  end
end
