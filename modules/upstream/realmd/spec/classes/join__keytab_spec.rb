require 'spec_helper'

describe 'realmd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "realmd::join::keytab class with default krb_config" do
          let(:params) do
            {
              :krb_ticket_join       => true,
              :domain_join_user      => 'user',
              :krb_keytab            => '/tmp/join.keytab',
              :krb_config_file       => '/etc/krb5.conf',
              :domain                => 'example.com',
              :manage_krb_config     => true,
            }
          end

          it { is_expected.to contain_class('realmd::join::keytab') }

          it do
            is_expected.to contain_file('krb_keytab').with({
              'path'  => '/tmp/join.keytab',
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0400',
            }).that_comes_before('Exec[run_kinit_with_keytab]')
          end

          it do
            is_expected.to contain_file('krb_configuration').with({
              'path'  => '/etc/krb5.conf',
              'owner' => 'root',
              'group' => 'root',
              'mode'  => '0644',
            }).that_comes_before('Exec[run_kinit_with_keytab]')
          end

          it do
            should contain_file('krb_configuration').with_content(
              /\[libdefaults\]\ndefault_realm = EXAMPLE.COM\n/
            )
          end

          it do
            should contain_file('krb_configuration').with_content(
              /dns_lookup_realm = true\n/
            )
          end

          it do
            should contain_file('krb_configuration').with_content(
              /dns_lookup_kdc = true\n/
            )
          end

          it do
            should contain_file('krb_configuration').with_content(
              /kdc_timesync = 0\n/
            )
          end

          it do
            is_expected.to contain_exec('run_kinit_with_keytab').with({
              'path'    => '/usr/bin:/usr/sbin:/bin',
              'command' => 'kinit -kt /tmp/join.keytab user',
              'unless'  => "klist -k /etc/krb5.keytab | grep -i 'foo@example.com'",
            }).that_comes_before('Exec[realm_join_with_keytab]')
          end

          it do
            is_expected.to contain_exec('realm_join_with_keytab').with({
              'path'    => '/usr/bin:/usr/sbin:/bin',
              'command' => 'realm join example.com',
              'unless'  => "klist -k /etc/krb5.keytab | grep -i 'foo@example.com'",
            })
          end
        end

        context "realmd::join::keytab class with custom krb_config" do
          let(:params) do
            {
              :krb_ticket_join   => true,
              :domain_join_user  => 'user',
              :krb_keytab        => '/tmp/join.keytab',
              :krb_config_file   => '/etc/krb5.conf',
              :domain            => 'example.com',
              :manage_krb_config => true,
              :krb_config        => {
                'libdefaults' => {
                  'default_realm' => 'EXAMPLE.COM',
                },
                'domain_realm' => {
                  'localhost.example.com' => 'EXAMPLE.COM',
                },
                'realms' => {
                  'EXAMPLE.COM' => {
                    'kdc' => 'dc.example.com:88',
                  },
                },
              }
            }
          end

          it { is_expected.to contain_class('realmd::join::keytab') }

          it do
            should contain_file('krb_configuration').with_content(
              /\[domain_realm\]\nlocalhost.example.com = EXAMPLE.COM\n/
            )
          end

          it do
            should contain_file('krb_configuration').with_content(
              /\[libdefaults\]\ndefault_realm = EXAMPLE.COM\n/
            )
          end

          it do
            should contain_file('krb_configuration').with_content(
              /\[realms\]\nEXAMPLE.COM = {\n  kdc = dc.example.com:88\n/
            )
          end
        end
      end
    end
  end
end
