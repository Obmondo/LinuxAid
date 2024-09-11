require 'spec_helper_acceptance'

RSpec.context 'when stripping whitespace from cron jobs' do
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

  agents.each do |host|
    it 'removes leading and trailing whitespace from cron jobs' do
      step 'apply the resource on the host using puppet resource'
      on(host, puppet_resource('cron', 'crontest', 'user=tstuser', "command='   date > /dev/null    '", 'ensure=present')) do
        expect(stdout).to match(%r{created})
      end

      step 'verify the added crontab entry has stripped whitespace'
      run_cron_on(host, :list, 'tstuser') do
        expect(stdout).to match(%r{\* \* \* \* \* date > .dev.null})
      end

      step 'apply the resource with trailing whitespace and check nothing happened'
      on(host, puppet_resource('cron', 'crontest', 'user=tstuser', "command='date > /dev/null    '", 'ensure=present')) do
        expect(stdout).not_to match(%r{ensure: created})
      end

      step 'apply the resource with leading whitespace and check nothing happened'
      on(host, puppet_resource('cron', 'crontest', 'user=tstuser', "command='     date > /dev/null'", 'ensure=present')) do
        expect(stdout).not_to match(%r{ensure: created})
      end
    end
  end
end
