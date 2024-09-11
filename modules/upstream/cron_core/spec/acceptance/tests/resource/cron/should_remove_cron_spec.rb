require 'spec_helper_acceptance'

RSpec.context 'when removing crontab' do
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
    it 'removes existing crontabs' do
      step 'create the existing job by hand...'
      run_cron_on(host, :add, 'tstuser', '* * * * * /bin/true')

      step 'apply the resource on the host using puppet resource'
      on(host, puppet_resource('cron', 'crontest', 'user=tstuser',
                               'command=/bin/true', 'ensure=absent')) do
        expect(stdout).to match(%r{crontest\D+ensure:\s+removed})
      end

      step ' contains what you expected'
      run_cron_on(host, :list, 'tstuser') do
        expect(stderr).not_to match(%r{/bin/true})
      end
    end
  end
end
