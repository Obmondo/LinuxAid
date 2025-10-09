# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Rsyslog expression filters' do
  before(:context) do
    cleanup_helper
  end

  context 'with simple expression filter' do
    it 'applies with a simply expression' do
      pp = <<-MANIFEST
      class { 'rsyslog::config':
        expression_filters => {
          'test_filter' => {
            'conditionals' => {
              'if' => {
                'expression' => 'msg == "test"',
                'tasks' => [
                  { 'call' => 'ruleset.action.test' },
                  { 'stop' => true },
                ]
              }
            }
          }
        }
      }
      MANIFEST

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/rsyslog.d/50_rsyslog.conf') do
      its(:content) { is_expected.to contain('if msg == "test" then {\n  call ruleset\.action\.test\n  stop\n\s*}') }
    end
  end
end
