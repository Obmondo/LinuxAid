require 'spec_helper'

describe 'realmd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "realmd::sssd::config class with custom config" do
          let(:params) do
            {
              :manage_sssd_config => true,
              :sssd_config        => {
                'sssd' => {
                  'domains'             => 'example.com',
                  'config_file_version' => '2',
                  'services'            => 'nss,pam',
                },
                'domain/example.com' => {
                  'ad_domain'                      => 'example.com',
                  'krb5_realm'                     => 'EXAMPLE.COM',
                  'id_provider'                    => 'ad',
                  'access_provider'                => 'ad',
                },
              }
            }
          end

          it do
            should contain_file('/etc/sssd/sssd.conf').with({
	            :owner => 'root',
	            :group => 'root',
	            :mode  => '0600'
            })
          end

          it { should contain_file('/etc/sssd/sssd.conf').that_notifies('Service[sssd]') }
          it { should contain_file('/etc/sssd/sssd.conf').that_notifies('Exec[force_config_cache_rebuild]') }
	        it { should contain_file('/etc/sssd/sssd.conf').with_content(/services = nss,pam/) }
	        it { should contain_file('/etc/sssd/sssd.conf').with_content(/\[domain\/example.com\]/) }
	        it { should contain_file('/etc/sssd/sssd.conf').with_content(/access_provider = ad/) }

          it do
            should contain_exec('force_config_cache_rebuild').with({
              'path'        => '/usr/bin:/usr/sbin:/bin',
              'command'     => 'rm -f /var/lib/sss/db/config.ldb',
              'refreshonly' => true,
            })
          end
        end
      end
    end
  end
end
