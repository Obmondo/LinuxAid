# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Rsyslog::Component::Ruleset' do
  before(:context) do
    cleanup_helper
  end

  it 'applies a ruleset' do
    pp = <<-MANIFEST
      class { 'rsyslog::config':
        rulesets => {
          'action.ruleset.test' => {
            'rules' => [
              {
                action => {
                  'name'   => 'action.test',
                  'type'   => 'omfile',
                  'config' => {
                    'queue.type'           => 'LinkedList',
                    'queue.spoolDirectory' => '/var/log/rsyslog/queue',
                    'file'                 => '/tmp/error_log',
                  }
                },
              }
            ]
          },
          'ruleset_eth0_514_test' => {
            'parameters' => {
              'queue.size' => '10000',
            },
            'rules' => [
              {
                'property_filter' => {
                  'property' => 'msg',
                  'operator' => 'contains',
                  'value'    => 'error',
                  'tasks'    => [
                    { 'call'     => 'action.ruleset.test' },
                    { 'stop'     => true }
                  ]
                }
              }
            ]
          }
        }
      }
    MANIFEST

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe file('/etc/rsyslog.d/50_rsyslog.conf') do
    it { is_expected.to be_file }
    it { is_expected.to be_readable }
    its(:content) { is_expected.to match(%r{# ruleset_eth0_514_test ruleset\nruleset \(name="ruleset_eth0_514_test"\n\s*queue\.size="10000"\n\) {\n# Property-based Filter\n:msg, contains, "error" {\n  call action\.ruleset\.test\n  stop\n\s*}\n\n}}) }
  end
end
