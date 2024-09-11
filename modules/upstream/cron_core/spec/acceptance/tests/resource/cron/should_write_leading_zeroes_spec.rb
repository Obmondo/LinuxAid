require 'spec_helper_acceptance'

RSpec.context 'when leading zeroes are present' do
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
    it 'does not ignore leading zeroes' do
      step 'apply the resource on the host' do
        on(host, puppet_resource('cron', 'crontest', 'user=tstuser', 'command=/bin/true', 'ensure=present', "minute='05'", "hour='007'", "weekday='03'", "month='0011'", "monthday='07'"), acceptable_exit_codes: [0])
      end

      step 'Verify that crontab -l contains what you expected' do
        run_cron_on(host, :list, 'tstuser') do
          expect(stdout).to match(%r{05 007 07 0011 03 /bin/true})
        end
      end
    end
  end
end
