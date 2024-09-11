require 'spec_helper_acceptance'

RSpec.context 'when Puppet authorizes a previously unauthorized user to use crontab' do
  let(:username) { "pl#{rand(999_999).to_i}" }
  let(:unauthorized_username) { "pl#{rand(999_999).to_i}" }

  let(:cron_deny_path) do
    {}
  end
  let(:cron_deny_original_contents) do
    {}
  end

  before(:each) do
    step 'Ensure that the test users exist' do
      compatible_agents.each do |agent|
        user_present(agent, username)
        user_present(agent, unauthorized_username)
      end
    end

    step 'Get the current cron.deny contents for each agent' do
      compatible_agents.each do |agent|
        case agent['platform']
        when %r{aix}
          cron_deny_path[agent] = '/var/adm/cron/cron.deny'
        when %r{solaris}
          cron_deny_path[agent] = '/etc/cron.d/cron.deny'
        else
          fail_test "Cannot figure out the path of the cron.deny file for the #{agent['platform']} platform"
        end

        cron_deny_original_contents[agent] = on(agent, "cat #{cron_deny_path[agent]}").stdout
      end
    end
  end

  after(:each) do
    step 'Teardown -- Erase the test users on the agents' do
      compatible_agents.each do |agent|
        run_cron_on(agent, :remove, username)
        user_absent(agent, username)

        run_cron_on(agent, :remove, unauthorized_username)
        user_absent(agent, unauthorized_username)
      end
    end

    # It is possible for the "before" hook to raise an exception while the
    # cron.deny contents are being computed, so only execute the next step
    # if we've managed to compute the cron.deny contents for each agent
    next unless cron_deny_original_contents.keys.size == compatible_agents.size

    step "Teardown -- Reset each agent's cron.deny contents" do
      compatible_agents.each do |agent|
        apply_manifest_on(agent, file_manifest(cron_deny_path[agent], ensure: :present, content: cron_deny_original_contents[agent]))
      end
    end
  end

  compatible_agents.each do |agent|
    is_aix_or_solaris_agent = agent['platform'].include?('aix') || agent['platform'].include?('solaris')

    it "should write that user's crontab on #{agent}", if: is_aix_or_solaris_agent do
      step 'Add the unauthorized user to the cron.deny file' do
        on(agent, "echo #{unauthorized_username} >> #{cron_deny_path[agent]}")
      end

      step 'Verify that the unauthorized user was added to the cron.deny file' do
        cron_deny_contents = on(agent, "cat #{cron_deny_path[agent]}").stdout
        assert_match(%r{^#{unauthorized_username}$}, cron_deny_contents, 'Failed to add the unauthorized user to the cron.deny file')
      end

      step "Modify the unauthorized user's crontab with Puppet" do
        # The scenario we're testing here is:
        #   * An unrelated cron resource triggers the prefetch step, which will also
        #   prefetch the crontab of our unauthorized user. The latter prefetch should
        #   fail, instead returning an empty crontab file.
        #
        #   * Puppet authorizes our unauthorized user by removing them from the cron.deny
        #   file.
        #
        #   * A cron resource linked to our (originally) unauthorized user should now be able
        #   to write to that user's crontab file (assuming it requires the resource updating
        #   the cron.deny file)
        #
        # The following manifest replicates the above scenario. Note that we test this specific
        # scenario to ensure that the changes in PUP-9217 enforce backwards compatibility.
        manifest = [
          cron_manifest('first_entry', command: 'ls', user: username),
          file_manifest(cron_deny_path[agent], ensure: :present, content: cron_deny_original_contents[agent]),
          cron_manifest('second_entry', command: 'ls', user: unauthorized_username),
        ].join("\n\n")
        apply_manifest_on(agent, manifest)
      end

      step "Verify that Puppet did modify the unauthorized user's crontab" do
        assert_matching_arrays(['* * * * * ls'], crontab_entries_of(agent, unauthorized_username), "Puppet did not modify the unauthorized user's crontab file")
      end
    end
  end
end
