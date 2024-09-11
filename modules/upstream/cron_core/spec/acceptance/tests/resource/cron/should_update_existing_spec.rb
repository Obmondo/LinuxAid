require 'spec_helper_acceptance'

RSpec.context 'when updating cron jobs' do
  before(:each) do
    compatible_agents.each do |agent|
      step 'ensure the user exists via puppet'
      setup(agent)

      step 'create the existing job by hand...'
      run_cron_on(agent, :add, 'tstuser', '* * * * * /bin/true')
    end
  end

  after(:each) do
    compatible_agents.each do |agent|
      step 'Cron: cleanup'
      clean(agent)
    end
  end

  compatible_agents.each do |host|
    it 'updates existing cron entries' do
      step 'verify that crontab -l contains what you expected'
      run_cron_on(host, :list, 'tstuser') do
        expect(stdout).to match(%r{\* \* \* \* \* /bin/true})
      end

      step 'apply the resource change on the host'
      on(host, puppet_resource('cron', 'crontest', 'user=tstuser', 'command=/bin/true', 'ensure=present', "hour='0-6'")) do
        expect(stdout).to match(%r{hour\s+=>\s+\['0-6'\]})
      end

      step 'verify that crontab -l contains what you expected'
      run_cron_on(host, :list, 'tstuser') do
        expect(stdout).to match(%r{\* 0-6 \* \* \* /bin/true})
      end
    end
  end
end
