require 'spec_helper'

describe 'simplib::reboot_notify' do
  context 'on supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_reboot_notify('__simplib_control__').with_log_level('notice') }
        it { is_expected.to create_reboot_notify('__simplib_control__').with_control_only(true) }
      end
    end
  end
end
