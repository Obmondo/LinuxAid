require 'spec_helper'
describe 'gerrit::params' do

  context 'with defaults' do
    it { is_expected.to contain_class('gerrit::params') }
  end
end

# vim: ts=2 sw=2 sts=2 et :
