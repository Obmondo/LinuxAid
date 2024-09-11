require 'spec_helper_acceptance'

test_name 'Augeasproviders Grub'

describe 'GRUB Menuentry Tests' do
  hosts_with_role(hosts, 'grub').each do |host|
    context 'set new default kernel in GRUB Legacy' do
      let(:manifest) { %(
        grub_menuentry { 'Standard':
          default_entry  => true,
          root           => '(hd0,0)',
          kernel         => ':preserve:',
          initrd         => ':preserve:',
          kernel_options => [':preserve:', 'iam=GROOT']
        }
      )}

      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, {:catch_changes => true})
      end

      it 'should have set the default to the new entry' do
        result = on(host, %(grubby --info=DEFAULT | grep 'args=')).stdout
        expect(result).to match(/iam=GROOT/)
      end

      it 'should activate on reboot' do
        host.reboot

        result = on(host, %(cat /proc/cmdline)).stdout
        expect(result.split(/\s+/)).to include('iam=GROOT')
      end
    end
  end

  hosts_with_role(hosts, 'grub2').each do |host|
    context 'set new default kernel in GRUB2' do
      let(:manifest) { %(
        grub_menuentry { 'Standard':
          default_entry  => true,
          root           => '(hd0,msdos1)',
          kernel         => ':preserve:',
          initrd         => ':preserve:',
          kernel_options => [':preserve:', 'trogdor=BURNINATE']
        }
      )}

      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, {:catch_changes => true})
      end

      it 'should have set the default to the new entry' do
        result = on(host, %(grubby --info=DEFAULT)).stdout
        result_hash = {}
        result.each_line do |line|
          line =~ /^\s*(.*?)=(.*)\s*$/
          result_hash[$1.strip] = $2.strip
        end

        expect(result_hash['title'].delete('"')).to eq('Standard')
        expect(result_hash['args'].delete('"')).to include('trogdor=BURNINATE')
      end

      it 'should activate on reboot' do
        host.reboot

        result = on(host, %(cat /proc/cmdline)).stdout
        expect(result.split(/\s+/)).to include('trogdor=BURNINATE')
      end
    end
  end
end
