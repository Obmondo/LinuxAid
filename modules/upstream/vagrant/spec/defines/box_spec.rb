require 'spec_helper'
describe 'vagrant::box' do

  context 'with title => bogus' do
    let(:title) { 'bogus' }
    it { should compile.with_all_deps }
    it { should contain_exec('foo-vagrant-box-bogus') }
  end
end
