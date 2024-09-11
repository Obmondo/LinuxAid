require 'serverspec'

set :backend, :exec

if os[:family] == 'redhat'
  apacheservice = 'httpd'
elsif ['debian', 'ubuntu'].include?(os[:family])
  apacheservice = 'apache2'
end

describe service(apacheservice) do
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe service('mysqld') do
  it { should be_running }
end

describe command('wget http://localhost') do
  its(:exit_status) { should eq 0 }
end

describe command('passenger-status') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /redmine/ }
end
