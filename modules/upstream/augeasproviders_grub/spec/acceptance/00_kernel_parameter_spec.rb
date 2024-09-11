require 'spec_helper_acceptance'

test_name 'Augeasproviders Grub'

describe 'Kernel Parameter Tests' do
  tests = {
    :basic => {
      :manifest => %(
        kernel_parameter { 'audit':
          value    => '1'
        }),
      :test => %(grep -q "audit=1" /proc/cmdline)
    },
    :normal_bootmode => {
      :manifest => %(
        kernel_parameter { 'audit':
          value    => '1',
          bootmode => 'normal'
        }),
      :test => %(grep -q "audit=1" /proc/cmdline)
    }
  }

  tests.keys.each do |key|
    let(:manifest){ tests[key][:manifest] }
    let(:test){ tests[key][:test] }

    context "default parameters for #{key}" do
      hosts.each do |host|
        # Using puppet_apply as a helper
        it 'should work with no errors' do
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, {:catch_changes => true})
        end

        it 'is expected to have auditing enabled at boot time' do
          # Scrub out any custom boot entries that were added by other GRUB2
          # tests
          on(host, 'rm -rf /etc/grub.d/05_puppet_managed*')
          on(host, 'which grub2-mkconfig > /dev/null 2>&1 && grub2-mkconfig -o /etc/grub2.cfg', :accept_all_exit_codes => true)

          host.reboot
          on(host, test)
        end
      end
    end
  end
end
