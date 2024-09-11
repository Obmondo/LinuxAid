require 'spec_helper_acceptance'

RSpec.context 'when removing crontabs' do
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
    it 'removes crontabs based on matching' do
      step 'Remove cron resource'
      on(host, puppet_resource('cron', 'bogus', 'user=tstuser', 'command=/bin/true', 'ensure=absent')) do
        expect(stdout).to match(%r{bogus\D+ensure: removed})
      end

      step 'verify that crontab -l contains what you expected'
      run_cron_on(host, :list, 'tstuser') do
        expect(stdout.scan('/bin/true').length).to eq(0)
      end
    end
  end
end
