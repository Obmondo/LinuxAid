require 'spec_helper'
describe 'vagrant' do

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_package('vagrant') }
  end
end
