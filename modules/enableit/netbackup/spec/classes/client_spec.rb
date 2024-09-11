require 'spec_helper'
describe 'netbackup::client' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do

      let(:params) {
        {
          :tmpinstaller    => '/tmp',
          :installer       => '/tmp/installer.expect',
          :version         => '7.6.0.1',
          :masterserver    => 'netbackup.xyz.com',
          :mediaservers    => ['mediaserver1.xyz.com', 'mediaserver2.xyz.com'],
          :clientname      => 'spectest.xyz.com',
          :service_enabled => true,
          :excludes        => ['/tmp', '/other/path'],
        }
      }

      let(:facts) do
        facts.merge({
          :netbackup_version => "7.5.0.0",
        })
      end


      it do
        should contain_class("netbackup::client::install").with({
          'installer'    => '/tmp/installer.expect',
          'version'      => '7.6.0.1',
          'masterserver' => 'netbackup.xyz.com',
          'clientname'   => 'spectest.xyz.com',
        })
        should contain_file("bp.conf").with({
          'content' => /SERVER = netbackup.xyz.com/,
          'content' => /CLIENT_NAME = spectest.xyz.com/,
        })
        should contain_file("exclude_list").with({
          'content' => /\/tmp/,
          'content' => /\/other\/path/,
        })
      end

      context 'with same version already installed' do
    
       let(:facts) do
         facts.merge({
           :netbackup_version => '7.6.0.1',
         })
       end

       let(:params) {
         {
           :version => '7.6.0.1',
         }
       }

       it do
          should_not contain_class("netbackup::client::install")
          should contain_service("netbackup-client").with({
            'name'   => 'netbackup',
            'ensure' => 'true',
          })
       end

      end

      context 'with newer version already installed' do

        let(:facts) do
          facts.merge({
            :netbackup_version => '7.6.0.3',
          })
        end

        let(:params) {
          {
            :version => '7.6.0.1',
          }
        }

        it do
          should_not contain_class("netbackup::client::install")
        end

      end

      context 'with older version already installed' do

        let(:facts) do
          facts.merge({
            :netbackup_version => '7.5.0.0',
          })
        end

        it do
          should contain_service("netbackup-client").with({
            'name'   => 'netbackup',
            'ensure' => 'true',
          })
          should contain_class("netbackup::client::install")
        end
      end

    end

    describe 'netbackup::client::install' do

      let(:params) {
        {
          :tmpinstaller    => '/tmp',
          :installer    => '/tmp/install_netbackup_client.expect',
          :version      => '7.6.0.1',
          :masterserver => 'netbackup.xyz.com',
          :clientname   => 'spectest.xyz.com',
        }
      }

      let(:facts) do
        facts.merge({
          :netbackup_version => '7.5.0.0',
        })
      end

      it do
        should contain_file('install_netbackup_client.expect').with({
          'path'    => '/tmp/install_netbackup_client.expect',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0744',
          'content' => /netbackup.xyz.com/,
        })
      end

    end

  end

end
