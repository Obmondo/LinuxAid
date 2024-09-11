# frozen_string_literal: true

require 'spec_helper'

def check_classes
  it do
    is_expected.to contain_class('ipset::params')
    is_expected.to contain_class('ipset::install')
  end
end

def check_file_set_header(name, attributes)
  it do
    is_expected.to contain_file("/etc/sysconfig/ipset.d/#{name}.hdr").
      only_with({
        ensure: 'file',
        owner: 'root',
        group: 'root',
        mode: '0640',
        notify: "Exec[sync_ipset_#{name}]"
      }.merge(attributes))
  end
end

def check_file_set_content(name, attributes)
  it do
    is_expected.to contain_file("/etc/sysconfig/ipset.d/#{name}.set").
      with({ ensure: 'file' }.merge(attributes))
  end
end

def check_exec_sync(name, attributes)
  it do
    is_expected.to contain_exec("sync_ipset_#{name}").
      with({
        path: ['/sbin', '/usr/sbin', '/bin', '/usr/bin', '/usr/local/bin', '/usr/local/sbin'],
        require: 'Package[ipset]'
      }.merge(attributes)).
      that_subscribes_to("File[/etc/sysconfig/ipset.d/#{name}.set]")
  end
end

simple_test_cases = [
  [
    'array',
    ['10.0.0.1', '192.168.0.1'],
    { content: "10.0.0.1\n192.168.0.1\n" }
  ],
  [
    'string',
    "10.0.0.1\n192.168.0.1\n",
    { content: "10.0.0.1\n192.168.0.1\n" }
  ],
  [
    'puppet url',
    'puppet:///foo/bar',
    { source: 'puppet:///foo/bar' }
  ],
  [
    'file url',
    'file:///foo/bar',
    { source: '/foo/bar' }
  ],
  [
    'array',
    ['10.0.0.1 #Comment 1', '192.168.0.1 #Comment 2'],
    { content: "10.0.0.1 #Comment 1\n192.168.0.1 #Comment 2\n" }
  ],
  [
    'array',
    ['10.0.0.1,80', '192.168.0.1,443'],
    { content: "10.0.0.1,80\n192.168.0.1,443\n" }
  ],
  [
    'string',
    ["10.0.0.1 #Comment 1\n192.168.0.1 #Comment 2"],
    { content: "10.0.0.1 #Comment 1\n192.168.0.1 #Comment 2\n" }
  ],
  [
    'string',
    ["10.0.0.1,80\n192.168.0.1,443"],
    { content: "10.0.0.1,80\n192.168.0.1,443\n" }
  ]
]

# rubocop:disable RSpec/MultipleDescribes
# rubocop:disable RSpec/EmptyExampleGroup
describe 'ipset::set' do
  simple_test_cases.each do |test_name, set, set_file_attributes|
    context "set type #{test_name}" do
      let :pre_condition do
        'include ipset'
      end
      let(:title) { 'simple' }
      let(:params) { { set: set } }
      let :facts do
        {
          os: {
            family: 'RedHat',
            release: {
              major: 7
            }
          },
          systemd: true,
          service_provider: 'systemd',
          operatingsystem: 'RedHat',
          osfamily: 'RedHat'
        }
      end

      check_file_set_header(
        'simple',
        content: "create simple hash:ip family inet hashsize 1024 maxelem 65536\n",
        # rubocop:enable Metrics/LineLength
      )
      check_file_set_content('simple', set_file_attributes)
      check_exec_sync(
        'simple',
        command: "ipset_sync -c '/etc/sysconfig/ipset.d'    -i simple",
        unless: "ipset_sync -c '/etc/sysconfig/ipset.d' -d -i simple",
        # rubocop:enable Metrics/LineLength
      )
    end
  end
end

describe 'ipset::set' do
  context 'custom parameters' do
    let :pre_condition do
      'include ipset'
    end
    let(:title) { 'custom' }
    let :params do
      {
        set: ['10.0.0.0/8', '192.168.0.0/16'],
        type: 'hash:net',
        options: { hashsize: 2048 },
        ignore_contents: true
      }
    end
    let :facts do
      {
        os: {
          family: 'RedHat',
          release: {
            major: 7
          }
        },
        systemd: true,
        service_provider: 'systemd'
      }
    end

    check_file_set_header(
      'custom',
      content: "create custom hash:net family inet hashsize 2048 maxelem 65536\n",
      # rubocop:enable Metrics/LineLength
    )
    check_file_set_content('custom', content: "10.0.0.0/8\n192.168.0.0/16\n")
    check_exec_sync(
      'custom',
      command: "ipset_sync -c '/etc/sysconfig/ipset.d'    -i custom -n",
      unless: "ipset_sync -c '/etc/sysconfig/ipset.d' -d -i custom -n",
      # rubocop:enable Metrics/LineLength
    )
  end
end
# rubocop:enable RSpec/EmptyExampleGroup

describe 'ipset::set' do
  # rubocop:enable RSpec/MultipleDescribes
  context 'absent' do
    let :pre_condition do
      'include ipset'
    end

    let(:title) { 'absent' }
    let :params do
      {
        ensure: 'absent',
        set: ['10.0.0.0/8', '192.168.0.0/16']
      }
    end

    let :facts do
      {
        os: {
          family: 'RedHat',
          release: {
            major: 7
          }
        },
        systemd: true,
        service_provider: 'systemd'
      }
    end

    it do
      is_expected.to contain_file('/etc/sysconfig/ipset.d/absent.hdr').
        with(ensure: 'absent')
      is_expected.to contain_file('/etc/sysconfig/ipset.d/absent.set').
        with(ensure: 'absent')
      is_expected.to contain_exec('ipset destroy absent').
        with(
          path: ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
          command: 'ipset destroy absent',
          onlyif: 'ipset list absent',
          require: 'Package[ipset]'
        )
    end
  end
end

describe 'ipset::set' do
  let(:title) { '123456789012345678901234567' }

  let :params do
    {
      ensure: 'present',
      set: ['10.0.0.0/8', '192.168.0.0/16']
    }
  end

  let :facts do
    {
      os: {
        family: 'RedHat',
        release: {
          major: 7
        }
      },
      systemd: true,
      service_provider: 'systemd'
    }
  end

  it { is_expected.not_to compile }
end
