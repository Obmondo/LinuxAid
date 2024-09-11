require 'spec_helper'

describe 'drbd', type: :class do
  it { is_expected.to contain_class('drbd::service') }
  it { is_expected.to contain_package('drbd') }
  it { is_expected.to contain_exec('modprobe drbd') }
  it { is_expected.to contain_file('/drbd') }
  it { is_expected.to contain_file('/etc/drbd.conf') }
  it { is_expected.to contain_file('/etc/drbd.d').with_ensure('directory').with_purge(true) }
  it do
    is_expected.to contain_file('/etc/drbd.d/global_common.conf').with_content %r{usage-count no;$}
    is_expected.to contain_file('/etc/drbd.d/global_common.conf').with_content %r{protocol C;$}
  end
end
