require 'spec_helper_acceptance'

RSpec.context 'when creating cron' do
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

  compatible_agents.each do |host|
    it 'creates a new cron job' do
      step 'apply the resource on the host using puppet resource'
      on(host, puppet_resource('cron', 'crontest', 'user=tstuser', 'command=/bin/true', 'ensure=present')) do
        expect(stdout).to match(%r{created})
      end

      step 'verify that crontab -l contains what you expected'
      run_cron_on(host, :list, 'tstuser') do
        expect(stdout).to match(%r{\* \* \* \* \* /bin/true})
      end
    end
  end
end
