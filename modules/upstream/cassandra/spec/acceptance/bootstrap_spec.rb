require 'spec_helper_acceptance'

osfamily = fact('osfamily')
roles = hosts[0]['roles']
t = TestManifests.new(roles, 0, 0)
bootstrap_pp = t.bootstrap_pp()

describe 'Test Entry Criteria' do
  it "Should work with no errors (#{osfamily})" do
    apply_manifest(bootstrap_pp, catch_failures: true)
    shell('[ -d /opt/rh/ruby200 ] && /usr/bin/gem install puppet -v 3.8.7 --no-rdoc --no-ri; true')
  end
end
