require 'spec_helper'
describe 'opendkim' do

  context 'with defaults for all parameters' do
    it { should contain_class('opendkim') }
  end
end
