require 'spec_helper'
describe 'perl' do

  context 'with defaults for all parameters' do
    it { should contain_class('perl') }
  end
end
