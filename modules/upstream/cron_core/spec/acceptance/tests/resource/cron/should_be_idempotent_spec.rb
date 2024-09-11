require 'spec_helper_acceptance'

RSpec.context 'when checking idempotency' do
  before(:each) do
    compatible_agents.each do |agent|
      step 'ensure the user exists via puppet'
      setup(agent)
    end
  end

  after(:each) do
    compatible_agents.each do |agent|
      step 'Cron: cleanup'
      clean(agent)
    end
  end

  compatible_agents.each do |agent|
    it "ensures idempotency on #{agent}" do
      step 'Cron: basic - verify that it can be created'
      result = apply_manifest_on(agent, 'cron { "myjob": command => "/bin/true", user    => "tstuser", hour    => "*", minute  => [1], ensure  => present,}')
      expect(result.stdout).to match(%r{ensure: created})

      result = run_cron_on(agent, :list, 'tstuser')
      expect(result.stdout).to match(%r{. . . . . .bin.true})

      step 'Cron: basic - should not create again'
      result = apply_manifest_on(agent, 'cron { "myjob": command => "/bin/true", user    => "tstuser", hour    => "*", minute  => [1], ensure  => present,}')
      expect(result.stdout).not_to match(%r{ensure: created})
    end
  end
end
