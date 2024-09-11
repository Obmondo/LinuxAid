require 'spec_helper'
describe 'rsnapshot' do
      let(:facts) {{ :osfamily => 'RedHat' }}

      it { should contain_class('rsnapshot::params') }
      it { is_expected.to compile  }
end
