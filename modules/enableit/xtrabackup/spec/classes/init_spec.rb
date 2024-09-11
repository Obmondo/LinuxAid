require 'spec_helper'
describe 'xtrabackup' do

  context 'with defaults for all parameters' do
    it { should contain_class('xtrabackup') }
  end
end
