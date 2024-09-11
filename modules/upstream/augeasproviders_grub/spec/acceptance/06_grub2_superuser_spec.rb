require 'spec_helper_acceptance'

test_name 'Augeasproviders Grub'

describe 'GRUB2 User Tests' do
  hosts_with_role(hosts, 'grub2').each do |host|
    context 'set a root superuser password' do
      let(:manifest) { %(
        grub_user { 'root':
          superuser => true,
          password  => 'P@ssw0rdP@ssw0rd'
        }
      )}

      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, {:catch_changes => true})
      end
    end

    context 'with multiple superusers' do
      let(:manifest) { %(
        grub_user { 'root':
          superuser => true,
          password  => 'P@ssw0rdP@ssw0rd'
        }

        grub_user { 'other_root':
          superuser => true,
          password  => 'P@ssw0rdP@ssw0rd'
        }
      )}

      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, {:catch_changes => true})
      end
    end
  end
end
