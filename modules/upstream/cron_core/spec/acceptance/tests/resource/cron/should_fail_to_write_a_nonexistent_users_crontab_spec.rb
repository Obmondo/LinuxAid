require 'spec_helper_acceptance'

RSpec.context 'when Puppet attempts to write the crontab of a nonexistent user' do
  let(:nonexistent_username) { "pl#{rand(999_999).to_i}" }

  before(:each) do
    step 'Ensure that the nonexistent user does not exist' do
      compatible_agents.each do |agent|
        user_absent(agent, nonexistent_username)
      end
    end
  end

  compatible_agents.each do |agent|
    it "should fail on #{agent}" do
      manifest = cron_manifest('second_entry', command: 'ls', user: nonexistent_username)
      apply_manifest_on(agent, manifest, expect_failures: true)
    end
  end
end
