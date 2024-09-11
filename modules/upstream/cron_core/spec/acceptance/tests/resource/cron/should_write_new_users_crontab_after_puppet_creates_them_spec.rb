require 'spec_helper_acceptance'

RSpec.context 'when Puppet creates a user in the middle of its run' do
  let(:known_username) { "pl#{rand(999_999).to_i}" }
  let(:new_username) { "pl#{rand(999_999).to_i}" }

  before(:each) do
    step 'Ensure that the known user exists on all of the agents' do
      compatible_agents.each do |agent|
        user_present(agent, known_username)
      end
    end

    step 'Ensure that the new user does not exist on all of the agents' do
      compatible_agents.each do |agent|
        user_absent(agent, new_username)
      end
    end
  end

  after(:each) do
    step 'Teardown -- Ensure that both users are deleted on all of the agents' do
      compatible_agents.each do |agent|
        run_cron_on(agent, :remove, known_username)
        user_absent(agent, known_username)

        run_cron_on(agent, :remove, new_username)
        user_absent(agent, new_username)
      end
    end
  end

  compatible_agents.each do |agent|
    it "should be able to write their crontab on #{agent}" do
      puppet_result = nil
      step "Create the new user, and the known + new user's crontab entries with Puppet" do
        # Placing Cron[first_entry] before creating the new user
        # triggers a prefetch of all the Cron resources on the
        # system. This lets us test that the prefetch step marks
        # the crontab of an unknown user as empty instead of marking
        # it as a failure.
        manifest = [
          cron_manifest('first_entry', command: 'ls', user: known_username),
          user_manifest(new_username, ensure: :present),
          cron_manifest('second_entry', command: 'ls', user: new_username),
        ].join("\n\n")
        puppet_result = apply_manifest_on(agent, manifest)
      end

      step 'Verify that Puppet successfully evaluates a Cron resource associated with the new user' do
        assert_match(%r{Cron.*second_entry}, puppet_result.stdout, 'Puppet fails to evaluate a Cron resource associated with a new user')
      end

      step "Verify that Puppet did create the new user's crontab file" do
        assert_matching_arrays(['* * * * * ls'], crontab_entries_of(agent, new_username), "Puppet did not create the new user's crontab file")
      end
    end
  end
end
