require 'spec_helper'
describe 'limits' do

  let :default_params do
    {
      :manage_limits_d_dir => true,
      :purge_limits_d_dir => true
    }
  end

  [ {},
    {
      :purge_limits_d_dir => false
    },
    {
      :manage_limits_d_dir => false
    }
  ].each do |param_set|
    describe "when #{param_set == {} ? "using default" : "specifying #{param_set}"} class parameters" do

      let :param_hash do
        default_params.merge(param_set)
      end

      let :params do
        param_set
      end

      ['Debian', 'Gentoo', 'RedHat', 'Suse'].each do |osfamily|

        let :facts do
          {
            :osfamily => osfamily,
          }
        end

        describe "on supported osfamily: #{osfamily}" do

          it { should contain_class('limits::params') }

          it do
            if params[:manage_limits_d_dir] == false
              should_not contain_file('/etc/security/limits.d')
            else
              should contain_file('/etc/security/limits.d').with(
              'ensure'  => 'directory',
              'owner'   => 'root',
              'group'   => 'root',
              'force'   => true,
              'recurse' => true,
              'purge'   => param_hash[:purge_limits_d_dir])
            end
          end
        end
      end
    end
  end
end
