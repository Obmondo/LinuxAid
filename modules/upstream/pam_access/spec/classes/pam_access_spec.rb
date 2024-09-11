require 'spec_helper'

describe 'pam_access', :type => :class do
  describe 'does stuff if os supported' do
    let(:facts) { { :osfamily => 'RedHat', :operatingsystemrelease => '7.1' } }
    let(:params) { { :manage_pam => false } }

    it { should compile.with_all_deps }

    it do
      should contain_file('/etc/security/access.conf').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644'
      )
    end

    describe 'execs authconfig-access' do
      let(:params) { { :manage_pam => true } }

      it { should compile.with_all_deps }

      it do
        should contain_exec('authconfig-access').with(
          :command => '/usr/sbin/authconfig --enablelocauthorize --enablepamaccess --update'
        )
      end
    end
  end
end
