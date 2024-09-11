require 'spec_helper'
describe 'passenger' do

  context 'with defaults for all parameters' do
    it { should contain_class('passenger') }
  end
end
