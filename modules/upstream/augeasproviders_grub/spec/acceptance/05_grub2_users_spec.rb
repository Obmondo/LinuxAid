require 'spec_helper_acceptance'

test_name 'Augeasproviders Grub'

describe 'GRUB2 User Tests' do
  hosts_with_role(hosts, 'grub2').each do |host|
    let(:target_files) {
      [
        '/etc/grub.d/02_puppet_managed_users',
        '/etc/grub2.cfg'
      ]
    }

    let(:password_info) {{
      :plain_password      => 'really bad password',
      :hashed_password     => 'grub.pbkdf2.sha512.10000.3ED7C861BA4107282E3A55FC80B549995D105324F2CB494BBF34DE86517DFCB8DCFCA3E0C3550C64F9A259B516BFDD928C0FAC4E66CFDA351A957D702EE32C3D.C589ED8757DB23957A5F946470A58CF216A7507634647E532BC68085AAA52622AB4E6E151CF60CD8409166F6581FC166CE4D4845D61353A4C439C2170CC25747',
      :hashed_password_20k => 'grub.pbkdf2.sha512.20000.4CD886B13634E03CF533C3F4C27E59E8F67D9C62915C04E03B019651FFB1DE8BE9EBB09B0D5759CF94A502566D748C28E9AF2150E81BFF1202E66D3C417A28A1.62E1AE32B4746DCBF222EB22FA670D35E7FAAD438677D67A0A1275E79430CF4E0F31EBF2186E645E922109B973CFF9A71BD53DCA77D9E749BDEC302022FD00BE'
    }}

    context 'set a user on the system with a plain text password' do
      let(:manifest) { %(
        grub_user { 'test_user1':
          password => '#{password_info[:plain_password]}'
        }
      )}

      let(:legacy_file) { '/etc/grub.d/01_puppet_managed_users' }

      # With a legacy file to be removed
      it 'should have a legacy file' do
        create_remote_file(host, legacy_file , '# Legacy File')
      end

      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should have removed the legacy file' do
        expect(host.file_exist?(legacy_file)).to be false
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, {:catch_changes => true})
      end

      it 'should set an encrypted password' do
        target_files.each do |target_file|
          result = on(host, %(grep 'password_pbkdf2 test_user1' #{target_file})).stdout

          password_identifier, user, password_hash = result.split(/\s+/)
          expect(user).to eql('test_user1')
          expect(password_hash).to match(/grub\.pbkdf2\.sha512\.10000\..*/)
        end
      end
    end

    context 'set a user on the system with a hashed password' do
      let(:manifest) { %(
        grub_user { 'test_user1':
          password => '#{password_info[:hashed_password]}'
        }
      )}

      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, :catch_changes => true)
      end

      it 'should set an encrypted password' do
        target_files.each do |target_file|
          result = on(host, %(grep 'password_pbkdf2 test_user1' #{target_file})).stdout

          password_identifier, user, password_hash = result.split(/\s+/)
          expect(user).to eql('test_user1')
          expect(password_hash).to eql(password_info[:hashed_password])
        end
      end
    end

    context 'set a user on the system with a hashed password with 20000 rounds' do
      let(:manifest) { %(
        grub_user { 'test_user1':
          password => '#{password_info[:hashed_password_20k]}',
          rounds   => '20000'
        }
      )}

      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, {:catch_changes => true})
      end

      it 'should set an encrypted password' do
        target_files.each do |target_file|
          result = on(host, %(grep 'password_pbkdf2 test_user1' #{target_file})).stdout

          password_identifier, user, password_hash = result.split(/\s+/)
          expect(user).to eql('test_user1')
          expect(password_hash).to eql(password_info[:hashed_password_20k])
        end
      end
    end

    context 'should purge any users when purge is set' do
      let(:manifest) { %(
        grub_user { 'test_user1':
          password => '#{password_info[:hashed_password]}',
          purge    => true
        }
      )}

      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(host, manifest, {:catch_changes => true})
      end

      it 'should purge unmanaged users' do
        on(host, %(puppet resource grub_user bad_user password='some password'))

        result = apply_manifest_on(host, manifest, :catch_failures => true).stdout
        expect(result).to match(/Purged.*bad_user/)

        target_files.each do |target_file|
          result = on(host, %(grep 'password_pbkdf2 test_user1' #{target_file})).stdout

          password_identifier, user, password_hash = result.split(/\s+/)
          expect(user).to eql('test_user1')
          expect(password_hash).to eql(password_info[:hashed_password])

          result = on(
            host,
            %(grep 'password_pbkdf2 bad_user' #{target_file}),
            :acceptable_exit_codes => [1]
          ).stdout
          expect(result).to be_empty
        end
      end
    end
  end
end
