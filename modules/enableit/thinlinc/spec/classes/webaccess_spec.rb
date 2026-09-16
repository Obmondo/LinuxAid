require 'spec_helper'

describe 'thinlinc::webaccess' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:config_file) { '/opt/thinlinc/etc/conf.d/webaccess.hconf' }

      it { is_expected.to compile }

      context 'with defaults' do
        # ThinLinc 4.19 does not know about these parameters, so they must not
        # be rendered unless they are configured explicitly.
        it 'does not render parameters added after 4.19' do
          content = catalogue.resource('file', config_file)[:content]

          expect(content).not_to match(%r{trusted_proxies=})
          expect(content).not_to match(%r{\[/webaccess/login\]})
          expect(content).not_to match(%r{\[/webaccess/branding\]})
          expect(content).not_to match(%r{\[/webaccess/oidc/})
        end
      end

      context 'with branding and OIDC configured' do
        let(:pre_condition) do
          <<~PP
            class { 'thinlinc':
              tlwebadm_password             => 'secret',
              webaccess_trusted_proxies     => ['10.45.13.45'],
              webaccess_branding_title      => 'Remote Desktop',
              webaccess_branding_logo       => '/opt/thinlinc/share/branding/logo.svg',
              webaccess_login_password      => false,
              webaccess_oidc                => {
                'entra' => {
                  'username_claim'     => 'preferred_username',
                  'discovery_url'      => 'https://login.example.com/.well-known/openid-configuration',
                  'client_id'          => 'thinlinc',
                  'client_secret_path' => '/opt/thinlinc/etc/oidc-entra.secret',
                  'scope'              => ['profile', 'email'],
                },
              },
            }
          PP
        end

        it { is_expected.to compile }

        it 'renders the new sections' do
          content = catalogue.resource('file', config_file)[:content]

          expect(content).to match(%r{^trusted_proxies=10\.45\.13\.45$})
          expect(content).to match(%r{^\[/webaccess/login\]$})
          expect(content).to match(%r{^password=false$})
          expect(content).to match(%r{^\[/webaccess/branding\]$})
          expect(content).to match(%r{^title=Remote Desktop$})
          expect(content).to match(%r{^\[/webaccess/oidc/entra\]$})
          expect(content).to match(%r{^scope=profile email$})
        end
      end

      context 'with password login disabled and no OIDC provider' do
        let(:pre_condition) do
          <<~PP
            class { 'thinlinc':
              tlwebadm_password        => 'secret',
              webaccess_login_password => false,
            }
          PP
        end

        it { is_expected.to compile.and_raise_error(%r{locks everyone out}) }
      end
    end
  end
end
