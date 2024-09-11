require 'spec_helper'
describe 'Sentry' do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'RedHat',
      operatingsystemrelease: '7.2',
      operatingsystemmajrelease: '7',
      os: {
        architecture: "x86_64",
        family: "RedHat",
        hardware: "x86_64",
        name: "RedHat",
        release: {
          full: "7.2",
          major: "7",
          minor: "2"
        },
        selinux: {
          config_mode: "permissive",
          config_policy: "targeted",
          current_mode: "permissive",
          enabled: true,
          enforced: false,
          policy_version: "28"
        }
      },
      python_version: '2.7.5'
    }
  end
  context 'all default values' do
    it { is_expected.to contain_class('sentry::setup') }
    it { is_expected.to contain_class('sentry::config') }
    it { is_expected.to contain_class('sentry::install') }
    it { is_expected.to contain_class('sentry::service') }
    it { is_expected.to contain_class('sentry::wsgi') }
  end

  context 'Sentry version < 8.4.0' do
    let (:params) {{ :version => '8.0.0' }}
    it "should fail" do
      expect { catalogue }.to raise_error(Puppet::Error, /Sentry version 8.4.0 or greater is required./)
    end
  end
end
