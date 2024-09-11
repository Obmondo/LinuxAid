require 'spec_helper'

describe 'mumble', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        it { should compile.with_all_deps }
        it { should contain_class('mumble') }
        it { should contain_file('/etc/mumble-server.ini') }
        it { should contain_group('mumble-server') }
        it { should contain_package('mumble-server') }
        it { should contain_service('mumble-server') }
        it { should contain_user('mumble-server') }
      end
    end
  end
end
