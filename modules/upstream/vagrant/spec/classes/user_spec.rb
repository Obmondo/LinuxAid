require 'spec_helper'

describe 'vagrant::user' do
  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_group('vagrant').that_comes_before('User[vagrant]') }
    it { should contain_user('vagrant').with_ensure('present') }
    it { should contain_group('vagrant').with_ensure('present') }
    it { should contain_file('/home/vagrant/.ssh').with_ensure('directory') }
    it { should contain_file('/home/vagrant/.ssh/authorized_keys').with_owner('vagrant') }
    it { should contain_file('/etc/sudoers.d/vagrant').with({
      'owner' => 'root',
      'mode'  => '0440'
      }) }
    it { should contain_file('/home/vagrant/.ssh/authorized_keys').with_content(/^ssh-rsa AAAA/) }
  end

  context 'user_name => bogus_user, group_name => bogus_group' do
    let(:user_name) { 'bogus_user' }
    let(:group_name) { 'bogus_group' }
    let(:params) { { :user_name => user_name, :group_name => group_name } }
    it { should compile.with_all_deps }
    it { should contain_group('bogus_group').that_comes_before('User[bogus_user]') }
    it { should contain_user(user_name).with_ensure('present') }
    it { should contain_group(group_name).with_ensure('present') }
  end

  context 'ensure => absent' do
    let(:params) { { :ensure => 'absent' } }
    it { should compile.with_all_deps }
    it { should contain_user('vagrant').that_comes_before('Group[vagrant]') }
    it { should contain_user('vagrant').with_ensure('absent') }
    it { should contain_group('vagrant').with_ensure('absent') }
    it { should contain_file('/home/vagrant/.ssh').with_ensure('absent') }
    it { should contain_file('/home/vagrant/.ssh/authorized_keys').with_ensure('absent') }
    it { should contain_file('/etc/sudoers.d/vagrant').with_ensure('absent') }
  end

  context 'sudo_ensure => absent' do
    let(:params) { { :sudo_ensure => 'absent' } }
    it { should compile.with_all_deps }
    it { should contain_user('vagrant').with_ensure('present') }
    it { should contain_group('vagrant').with_ensure('present') }
    it { should contain_file('/etc/sudoers.d/vagrant').with_ensure('absent') }
  end
end
