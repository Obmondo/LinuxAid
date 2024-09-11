require 'spec_helper'
describe 'netbackup' do

  context 'with defaults for all parameters' do
    it { should contain_class('netbackup') }
  end
end
