require 'spec_helper'
describe 'vagrant::command' do

  context 'with title => bogus' do
    let(:title) { 'bogus' }
    it { should compile.with_all_deps }
    it { should contain_exec('bogus') }
  end
end
