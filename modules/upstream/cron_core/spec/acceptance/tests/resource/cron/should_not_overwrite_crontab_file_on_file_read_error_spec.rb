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
  let(:crontab_contents) { '6 6 6 6 6 /usr/bin/true' }

  before(:each) do
    compatible_agents.each do |agent|
      next if older_agent?(agent)

      step "Create the user on #{agent}" do
        user_present(agent, username)
      end

      step "Set the user's crontab on #{agent}" do
        run_cron_on(agent, :add, username, crontab_contents)
        assert_matching_arrays([crontab_contents], crontab_entries_of(agent, username), "Could not set the user's crontab for testing")
      end
    end
  end

  after(:each) do
    compatible_agents.each do |agent|
      next if older_agent?(agent)

      step "Teardown -- Erase the user on #{agent}" do
        run_cron_on(agent, :remove, username)
        user_absent(agent, username)
      end
    end
  end

  compatible_agents.each do |agent|
    it "should not overwrite it on #{agent}" do
      if older_agent?(agent)
        skip('Skipping this test since we are on an older agent that does not have the PUP-9217 changes')
      end

      crontab_exe = nil
      step 'Find the crontab executable' do
        crontab_exe = on(agent, 'which crontab').stdout.chomp
      end

      stub_crontab_bin_dir = nil
      stub_crontab_exe = nil
      step 'Create the stub crontab executable that triggers the read error' do
        stub_crontab_bin_dir = agent.tmpdir('stub_crontab_bin_dir')
        on(agent, "chown #{username} #{stub_crontab_bin_dir}")

        stub_crontab_exe = "#{stub_crontab_bin_dir}/crontab"
        stub_crontab_exe_script = <<-SCRIPT
  #!/usr/bin/env bash
  exit 1
  SCRIPT
        create_remote_file(agent, stub_crontab_exe, stub_crontab_exe_script)
        on(agent, "chown #{username} #{stub_crontab_exe}")
        on(agent, "chmod a+x #{stub_crontab_exe}")
      end

      path_env_var = nil
      step 'Get the value of the PATH environment variable' do
        path_env_var = on(agent, 'echo $PATH').stdout.chomp
      end

      step "(PUP-9217) Attempt to overwrite the user's crontab file" do
        # This manifest reproduces the issue in PUP-9217. Here's how:
        #   1. When Puppet attempts to realize Cron['first_entry'], it will prefetch
        #   all of the present cron entries on the system. To do this, it will execute
        #   the crontab command. Since we prepend stub_crontab_bindir to PATH prior to
        #   executing Puppet, executing the crontab command will really execute
        #   stub_crontab_exe, which returns an exit code of 1. This triggers our
        #   read error.
        #
        #   2. Puppet will attempt to write Cron['first_entry'] onto disk. However, it will
        #   fail to do so because it will still execute stub_crontab_exe to perform the
        #   write. Thus, Cron['first_entry'] will fail its evaluation.
        #
        #   3. Next, Puppet will modify stub_crontab_exe to now execute the actual crontab
        #   command so that any subsequent calls to crontab will succeed. Note that under
        #   the hood, Puppet will still be executing stub_crontab_exe.
        #
        #   4. Finally, Puppet will attempt to realize Cron['second_entry']. It will skip
        #   the prefetch step, instead proceeding to directly write Cron['second_entry']
        #   to disk. But note that since the prefetch failed in (1), Puppet will proceed
        #   to overwrite our user's crontab file so that it will contain Cron['first_entry']
        #   and Cron['second_entry'] (Cron['first_entry'] is there because Puppet maintains
        #   each crontab file's entries in memory so that when it writes one entry to disk,
        #   it will write all of them).
        manifest = [
          cron_manifest('first_entry', command: 'ls', user: username),
          file_manifest(stub_crontab_exe, content: "#!/usr/bin/env bash\n#{crontab_exe} $@"),
          cron_manifest('second_entry', command: 'ls', user: username),
        ].join("\n\n")
        manifest_file = agent.tmpfile('crontab_overwrite_manifest')
        create_remote_file(agent, manifest_file, manifest)

        # We need to run a script here instead of a command because:
        #   * We need to cd into a directory owned by our user. Otherwise, bash will
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

        on(agent, "bash #{apply_crontab_overwrite_manifest}", environment: { PATH: "#{stub_crontab_bin_dir}:#{path_env_var}" })
      end

      step "(PUP-9217) Verify that Puppet does not overwrite the user's crontab file when it fails to read it" do
        assert_matching_arrays([crontab_contents], crontab_entries_of(agent, username), "Puppet overwrote the user's crontab file even though it failed to read it")
      end
    end
  end
end
