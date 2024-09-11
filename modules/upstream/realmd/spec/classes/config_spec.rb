require 'spec_helper'

describe 'realmd' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "realmd::config class with default parameters" do
          let(:params) {{ }}

          it do
            should contain_file('/etc/realmd.conf').with({
	          :owner => 'root',
	          :group => 'root',
	          :mode  => '0640',
          })
          end
        end
      end
    end
  end
end
