require 'spec_helper'
describe 'limits::limits', :type => :define do
  let(:filename) { '/etc/security/limits.d/username_nofile.conf' }

  let :facts do
    {
      :osfamily => 'Debian'
    }
  end
  context 'default' do
    let(:title)    { 'username_nofile' }
    let :params do
        {
        :user       => 'username',
        :limit_type => 'nofile',
        :ensure     => 'present',
        :hard       => '16384',
        :soft       => '16384'
        }
    end

    describe "when creating a limits entry not ending in .conf" do
      it { should compile.with_all_deps }
      it { should contain_class('limits') }
      it { should contain_limits__limits('username_nofile').with({
          :user       => 'username',
          :limit_type => 'nofile',
          :ensure     => 'present',
          :hard       => '16384',
          :soft       => '16384'
        })
      }
      it { should contain_file(filename).with({
          'ensure'    => 'present',
          'content'   => "# Managed by Puppet\n\n#<domain>    <type> <item>          <value>\nusername      hard  nofile          16384\nusername      soft  nofile          16384\n",
          'owner'     => 'root',
          'group'     => 'root',
        })
      }
    end

    describe "when creating a limits entry ending in .conf" do
      let(:title)    { 'username_nofile.conf' }
      it { should contain_limits__limits('username_nofile.conf').with({
          :user       => 'username',
          :limit_type => 'nofile',
          :ensure     => 'present',
          :hard       => '16384',
          :soft       => '16384'
        })
      }
      it { should contain_file(filename).with({
          'ensure'    => 'present',
          'content'   => "# Managed by Puppet\n\n#<domain>    <type> <item>          <value>\nusername      hard  nofile          16384\nusername      soft  nofile          16384\n",
          'owner'     => 'root',
          'group'     => 'root',
        })
      }
    end

    describe "when removing an limits entry" do
      let :params do
        {
        :user       => 'username',
        :limit_type => 'nofile',
        :ensure     => 'absent',
        :hard       => '16384',
        :soft       => '16384'
        }
      end
      it { should contain_file(filename).with({
          'ensure'    => 'absent',
          'content'   => "# Managed by Puppet\n\n#<domain>    <type> <item>          <value>\nusername      hard  nofile          16384\nusername      soft  nofile          16384\n",
          'owner'     => 'root',
          'group'     => 'root',
        })
      }

    end

    context "when creating a limits entry setting both limits" do
      let :params do
        {
          :user       => 'username',
          :limit_type => 'nofile',
          :ensure     => 'present',
          :both       => '16384'
        }
      end
      let(:title)    { 'username_nofile.conf' }
      it { should contain_limits__limits('username_nofile.conf').with({
          :user       => 'username',
          :limit_type => 'nofile',
          :ensure     => 'present',
          :both       => '16384'
        })
      }
      it { should contain_file(filename).with({
          'ensure'    => 'present',
          'content'   => "# Managed by Puppet\n\n#<domain>    <type> <item>          <value>\nusername      -     nofile          16384\n",
          'owner'     => 'root',
          'group'     => 'root',
        })
      }
    end
  end
  context "title pattern" do

    describe "default/nofile" do
      let(:title)    { '*/nofile' }
      let :params do
        {
          :both       => '16384'
        }
      end
      it { should compile.with_all_deps }
      it { should contain_file('/etc/security/limits.d/default_nofile.conf').with({
          'ensure'    => 'present',
          'content'   => "# Managed by Puppet\n\n#<domain>    <type> <item>          <value>\n*             -     nofile          16384\n",
          'owner'     => 'root',
          'group'     => 'root',
        })
      }
    end

    describe "root/nofile" do
      let(:title)    { 'root/nofile' }
      let :params do
        {
          :hard       => '12345'
        }
      end
      it { should contain_file('/etc/security/limits.d/root_nofile.conf').with({
          'ensure'    => 'present',
          'content'   => "# Managed by Puppet\n\n#<domain>    <type> <item>          <value>\nroot          hard  nofile          12345\n",
          'owner'     => 'root',
          'group'     => 'root',
        })
      }
    end
  end

  context "validation" do
    describe "missing user" do
      let(:title)    { 'nofile' }
      let :params do
        {
          :limit_type => 'nofile',
          :both       => '16384'
        }
      end
      it { should compile.and_raise_error(/when not using the title pattern/) }
    end
    describe "missing type" do
      let(:title)    { 'nofile.conf' }
      let :params do
        {
          :user => 'foo',
          :both => '16384'
        }
      end
      it { should compile.and_raise_error(/when not using the title pattern/) }
    end
    describe "missing limit" do
      let(:title)    { 'root/nofile' }
      it { should compile.and_raise_error(/\$hard, \$soft or \$both is required/) }
    end
  end
end
