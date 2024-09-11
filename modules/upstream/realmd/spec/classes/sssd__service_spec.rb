require 'spec_helper'

describe 'realmd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "realmd::sssd::service class with default parameters" do
          let(:params) {{ }}

          it { is_expected.to contain_class('realmd::sssd::service') }

          it do
            is_expected.to contain_service('sssd').with(
              :ensure     => 'running',
              :enable     => true,
            )
          end
        end
      end
    end
  end
end
