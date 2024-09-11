require 'spec_helper'

describe 'jenkins::master' do
  let(:facts) do
    {
      osfamily: 'RedHat',
      operatingsystem: 'CentOS',
      operatingsystemrelease: '6.7',
      operatingsystemmajrelease: '6'
    }
  end

  let(:params) { { version: '1.2.3' } }
  let :pre_condition do
    'include jenkins'
  end

  it { is_expected.to contain_jenkins__plugin('swarm').with_version('1.2.3') }
end
