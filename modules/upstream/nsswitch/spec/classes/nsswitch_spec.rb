require 'spec_helper'

describe 'nsswitch', type: :class do
  %w[CentOS RedHat Amazon CloudLinux OracleLinux Scientific Fedora SLES Solaris Debian Ubuntu Gentoo LinuxMint].each do |os|
    context "when used with default parameter on #{os}" do
      let(:facts) { { operatingsystem: os } }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_resource_count(1) }
    end
  end

  context 'when used with default parameters on Enterprise Linux' do
    let(:facts) do
      {
        operatingsystem: 'RedHat',
      }
    end

    context 'version 6' do
      let(:facts) do
        super().merge(operatingsystemmajrelease: '6')
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_resource_count(1) }
    end

    context 'version 7' do
      let(:facts) do
        super().merge(operatingsystemmajrelease: '7')
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to have_resource_count(1) }
    end
  end

  context 'when used on an unsupported Operating System' do
    let(:facts) do
      {
        operatingsystem: 'unsupported',
      }
    end

    it do
      expect { catalogue }.to raise_error(%r{is not a supported operating system\.})
    end
  end

  context 'when passed parameters' do
    let(:facts) do
      {
        operatingsystem: 'CentOS',
      }
    end

    context 'every parameter will accept type of STRING' do
      let(:params) do
        {
          aliases: 'foo',
          automount: 'foo',
          bootparams: 'foo',
          ethers: 'foo',
          group: 'foo',
          hosts: 'foo',
          netgroup: 'foo',
          netmasks: 'foo',
          networks: 'foo',
          passwd: 'foo',
          protocols: 'foo',
          publickey: 'foo',
          rpc: 'foo',
          services: 'foo',
          shadow: 'foo',
          sudoers: 'foo',
        }
      end

      it { is_expected.to compile }
    end

    context 'every parameter will accept type of ARRAY' do
      let(:params) do
        {
          aliases: ['foo'],
          automount: ['foo'],
          bootparams: ['foo'],
          ethers: ['foo'],
          group: ['foo'],
          hosts: ['foo'],
          netgroup: ['foo'],
          netmasks: ['foo'],
          networks: ['foo'],
          passwd: ['foo'],
          protocols: ['foo'],
          publickey: ['foo'],
          rpc: ['foo'],
          services: ['foo'],
          shadow: ['foo'],
          sudoers: ['foo'],
        }
      end

      it { is_expected.to compile }
    end
  end
end
