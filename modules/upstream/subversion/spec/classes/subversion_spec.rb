require 'spec_helper'

describe 'subversion' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge({
        :augeasversion => '1.3.0'
      }) }
      let(:pre_condition) { 'include ::augeas' }

      it { is_expected.to compile }
    end
  end
end
