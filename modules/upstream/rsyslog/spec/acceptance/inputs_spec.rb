# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Rsyslog inputs' do
  before(:context) do
    cleanup_helper
  end

  context 'basic input' do
    it 'applies with inputs' do
      pp = <<-MANIFEST
      class { 'rsyslog::config':
        modules => {
          'imudp'  => {},
          'imptcp' => {},
        },
        inputs => {
          'imudp' => {
            'type'  => 'imudp',
            'config' => {
              'port' => '514',
            },
          },
          'imptcp' => {
            'type'  => 'imptcp',
            'config' => {
              'port' => '514',
            },
          },
        },
        actions => {
          'default_output' => {
            'type' => 'omfile',
            'config' => {
              'queue.type'           => 'LinkedList',
              'queue.spoolDirectory' => '/var/log/rsyslog/queue',
              'file'                 => '/tmp/log',
            },
          },
        },
      }
      MANIFEST

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/rsyslog.d/50_rsyslog.conf') do
      its(:content) { is_expected.to contain('input\(type="imudp"\n\s*port="514"\n\)') }
      its(:content) { is_expected.to contain('input\(type="imptcp"\n\s*port="514"\n\)') }
    end
  end

  context 'inputs with custom priorities' do
    it 'applies with custom priorities' do
      pp = <<~MANIFEST
        class { 'rsyslog::config':
                modules => {
                  'imfile' => {
                    'priority' => 5,
                  },
                  'imudp'  => {
                    'priority' => 5,
                  },
                  'imptcp' => {
                    'priority' => 5,
                  },
                },
                inputs => {
                  'imfile' => {
                    'priority' => 10,
                    'type'     => 'imfile',
                    'config'   => {
                      'File' => '/tmp/test-file',
                    },
                  },
                  'imudp' => {
                    'priority' => 111,
                    'type'     => 'imudp',
                    'config'   => {
                      'port' => '514',
                    },
                  },
                  'imptcp' => {
                    'priority' => 112,
                    'type'     => 'imptcp',
                    'config'   => {
                      'port' => '514',
                    },
                  },
                  'imfile2' => {
                    'priority' => 50,
                    'type'     => 'imfile',
                    'config'   => {
                      'File' => '/tmp/test-file2',
                    },
                  },
                },
                actions => {
                  'default_output' => {
                    'priority' => 113,
                    'type'     => 'omfile',
                    'config'   => {
                      'queue.type'           => 'LinkedList',
                      'queue.spoolDirectory' => '/var/log/rsyslog/queue',
                      'file'                 => '/tmp/log',
                    }
                  },
                },
              }
      MANIFEST

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/rsyslog.d/50_rsyslog.conf') do
      its(:content) { is_expected.to contain('input\(type="imfile"\n\s*File="/tmp/test-file"\n\)\n# imfile2\n') }
      its(:content) { is_expected.to contain('input\(type="imfile"\n\s*File="/tmp/test-file2"\n\)\n# imudp\n') }
      its(:content) { is_expected.to contain('input\(type="imudp"\n\s*port="514"\n\)\n# imptcp\n') }
      its(:content) { is_expected.to contain('input\(type="imptcp"\n\s*port="514"\n\)\n') }
    end
  end
end
