# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'Rsyslog actions' do
  before(:context) do
    cleanup_helper
  end

  context 'basic action' do
    it 'applies with action' do
      pp = <<-MANIFEST
      if $facts['os']['name'] == 'Fedora' {
        package { 'rsyslog-elasticsearch': ensure => installed }
      }

      class { 'rsyslog::config':
        actions => {
          'omfile_all_logs' => {
            'type'   => 'omfile',
            'config' => {
              'queue.type'           => 'LinkedList',
              'queue.spoolDirectory' => '/var/log/rsyslog/queue',
              'file'                 => '/tmp/log',
            }
          },
          'myaction' => {
            'type'   => 'omelasticsearch',
            'config' => {
              'host'                 => ["127.0.0.1", "192.168.0.1"],
              'queue.type'           => 'linkedlist',
              'queue.spoolDirectory' => '/var/log/rsyslog/queue'
            }
          }
        }
      }
      MANIFEST

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/rsyslog.d/50_rsyslog.conf') do
      its(:content) do
        is_expected.to match(%r{# omfile_all_logs\naction\(type="omfile"\n.*name="omfile_all_logs"\n.*queue.type="LinkedList"\n.*queue.spoolDirectory="/var/log/rsyslog/queue"\n.*file="/tmp/log"\n.*\)})
        is_expected.to match(%r{# myaction\naction\(type="omelasticsearch"\n.*name="myaction"\n.*host=\["127.0.0.1", "192.168.0.1"\]\n.*queue.type="linkedlist"\n.*queue.spoolDirectory="/var/log/rsyslog/queue"\n.*\)})
      end
    end

    # rm the rsyslog-elasticsearch package as it will block the uninstall of
    # the rsyslog package in other acceptance tests
    if fact('os.name') == 'Fedora'
      it 'applies with action' do
        pp = <<-MANIFEST
        if $facts['os']['name'] == 'Fedora' {
          package { 'rsyslog-elasticsearch': ensure => absent }
        }
        MANIFEST

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end
    end
  end
end
