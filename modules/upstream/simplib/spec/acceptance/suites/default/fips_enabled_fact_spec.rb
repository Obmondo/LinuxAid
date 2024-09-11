require 'spec_helper_acceptance'

test_name 'fips_enabled fact'
if ENV['BEAKER_fips'] == 'yes'
  fips_state = 'enabled'
  expected_fips_enabled = true
else
  fips_state = 'disabled'
  expected_fips_enabled = false
end

describe 'fips_enabled fact' do

  hosts.each do |host|
    context "when FIPS is #{fips_state} on #{host}" do
      it "fips_enabled fact should be #{expected_fips_enabled}" do
        results = on(host, 'puppet facts')
        expect(results.output).to match(/"fips_enabled": #{expected_fips_enabled}/)
      end
    end
  end
end
