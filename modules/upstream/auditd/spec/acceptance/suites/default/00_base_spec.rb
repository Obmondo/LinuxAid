require 'spec_helper_acceptance'

test_name 'auditd class with simp audit profile'

describe 'auditd class with simp audit profile' do
  require_relative('lib/util')

  let(:hieradata) {
    {
      'simp_options::syslog'    => true,
      'pki::cacerts_sources'    => ['file:///etc/pki/simp-testing/pki/cacerts'] ,
      'pki::private_key_source' => "file:///etc/pki/simp-testing/pki/private/%{fqdn}.pem",
      'pki::public_key_source'  => "file:///etc/pki/simp-testing/pki/public/%{fqdn}.pub",
      'rsyslog::config::main_msg_queue_size' => 4321,
    }
  }

  let(:enable_audit_messages) {
    {
      'auditd::syslog' => true,
      'auditd::config::audisp::syslog::enable' => true,
      'auditd::config::audisp::syslog::drop_audit_logs' => false,
      'auditd::config::audisp::syslog::priority' => 'LOG_NOTICE'
    }.merge(hieradata)
  }

  let(:disable_audit_messages) {
    {
      'auditd::config::audisp::syslog::enable' => false,
      'auditd::config::audisp::syslog::syslog_priority' => 'LOG_NOTICE',
      'auditd::syslog' => true
    }.merge(hieradata)
  }

  let(:manifest) {
    <<-EOS
      class { 'auditd': }
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      context 'default parameters' do
        it 'should work with no errors' do
          set_hieradata_on(host, hieradata)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should require reboot on subsequent run' do
          result = apply_manifest_on(host, manifest, :catch_failures => true)
          expect(result.output).to include('audit => modified')
          # Reboot to enable auditing in the kernel
          host.reboot
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, :catch_changes => true)
        end

        it 'should have kernel-level audit enabled on reboot' do
          on(host, 'grep "audit=1" /proc/cmdline')
        end

        it 'should have the audit package installed' do
          result = on(host, 'puppet resource package audit')
          expect(result.output).to_not include("ensure => 'absent'")
        end

        it 'should activate the auditd service' do
          result = on(host, 'puppet resource service auditd')
          expect(result.output).to include("ensure => 'running'")
          expect(result.output).to include("enable => 'true'")
        end

        it 'should load valid rules' do
          results = AuditdTestUtil::AuditdRules.new(host)

          expect(results.rules).to_not be_empty
          expect(results.warnings).to eq([])
          expect(results.errors).to eq([])
        end

        it 'should not send audit logs to syslog' do
          # log rotate so any audit messages present before the apply turned off
          # audit record logging are no longer in /var/log/secure
          on(host, 'logrotate --force /etc/logrotate.d/syslog; service rsyslog restart; sleep 2')
          # cause an auditable event
          on(host,'useradd thing1')
          on(host, %q(grep -qe 'acct="thing1".*exe="/usr/sbin/useradd"' /var/log/audit/audit.log))
          on(host, %q(grep -qe 'audispd.*msg=audit' /var/log/secure), :acceptable_exit_codes => [1,2])
        end

        it 'should fix incorrect permissions' do
          on(host, 'chmod 400 /var/log/audit/audit.log')
          apply_manifest_on(host, manifest, :catch_failures => true)
          result = on(host, "/bin/find /var/log/audit/audit.log -perm 0600")
          expect(result.output).to include('/var/log/audit/audit.log')
        end
      end

      context 'allowing audit syslog messages' do
        result = on(host, 'rpm -q --qf "%{VERSION}\n" audit')
        audit_version = result.stdout
        audit_major_version = audit_version.split(".")[0].to_i

        if audit_major_version < 3
          dispatcher = 'audispd'
        else
          dispatcher = 'audisp-syslog'
        end

        it 'should work with no errors' do
          set_hieradata_on(host, enable_audit_messages)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be running the audit dispatcher' do
          on(host, "pgrep #{dispatcher}")
        end

        it 'should have audit.rules has been generated with SIMP rules' do
          # spot check that audit.rules has been generated with SIMP rules
          on(host, %q(grep -qe '^-c$' /etc/audit/audit.rules))
          on(host, %q(grep -qe '\-a never,exit \-F auid=-1' /etc/audit/audit.rules))
          on(host, %q(grep -qe '\-a exit,always \-F perm=a \-F exit=-EACCES \-k access' /etc/audit/audit.rules))
          on(host, %q(grep -qe '\-w /var/log/audit -p wa \-k audit-logs' /etc/audit/audit.rules))
          # spot check that loaded audit rules contain SIMP rules
          # NOTE:  Loaded rules are normalized as follows:
          #   - Implicit '-S all' is included in '-a' rules without a '-S' option
          #   - '-a' arguments are reordered to have action,list instead of list,action.
          #   - '-k keyname' arguments are expanded to '-F key=keyname' for '-a' rules
          result = on(host, "auditctl -l")
          expect(result.output).to include('-a never,exit -S all -F auid=-1')
          expect(result.output).to include('-a always,exit -S all -F perm=a -F exit=-EACCES -F key=access')
          # On El6 it adds / to the end of directories but not on later versions.
          expect(result.output).to match(/-w \/var\/log\/audit[\/]* \-p wa \-k audit\-logs/)
        end

        it 'should send audit logs to syslog' do
          on(host, 'logrotate --force /etc/logrotate.d/syslog')

          # cause an auditable event and verify it is logged
          # log rotate so any audit messages present before the apply turned off
          # audit record logging are no longer in /var/log/secure
          on(host,'useradd thing2')
          on(host, %q(grep -qe 'acct="thing2".*exe="/usr/sbin/useradd"' /var/log/audit/audit.log))
          on(host, %q(grep -qe 'audispd.*type=SYSCALL msg=audit.*comm="useradd.*key="audit_account_changes"' /var/log/secure))
        end

        it 'should restart the dispatcher if killed' do
          on(host, "pkill #{dispatcher}")
          apply_manifest_on(host, manifest, :catch_failures => true)
          on(host, "pgrep #{dispatcher}")
        end
      end

      context 'disable audit syslog messages' do
        it 'should work with no errors' do
          set_hieradata_on(host, disable_audit_messages)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end
        it 'should not be logging messages to syslog' do
          # log rotate so any audit messages present before the apply turned off
          # audit record logging are no longer in /var/log/secure
          on(host, 'logrotate --force /etc/logrotate.d/syslog')
          on(host,'useradd notathing')
          on(host, %q(grep -qe 'audispd.*acct="notathing"' /var/log/secure), :acceptable_exit_codes => [1,2])
          on(host, %q(grep -qe 'acct="notathing".*exe="/usr/sbin/useradd"' /var/log/audit/audit.log))
        end
      end
    end
  end
end
