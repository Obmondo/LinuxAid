require 'spec_helper_acceptance'

describe 'cassandra' do
  roles = hosts[0]['roles']
  versions = []
  versions.push(2.1) if roles.include? 'cassandra2'
  versions.push(2.2) if roles.include? 'cassandra2'
  versions.push(3.0) if roles.include? 'cassandra3'

  versions.each do |version|
    t = TestManifests.new(roles, version, fact('operatingsystemmajrelease'))

    describe "Cassandra #{version} installation." do
      # firewall_pp = t.firewall_pp()
      cassandra_install_pp = t.cassandra_install_pp

      it 'works with no errors' do
        apply_manifest(cassandra_install_pp, catch_failures: true)
      end

      it 'check code is idempotent' do
        expect(apply_manifest(cassandra_install_pp,
                              catch_failures: true).exit_code).to be_zero
      end
    end

    describe service('cassandra') do
      it "check Cassandra-#{version} is running and enabled" do
        is_expected.to be_running
        is_expected.to be_enabled
      end
    end

    if fact('osfamily') == 'RedHat'
      describe service('datastax-agent') do
        it 'check service status' do
          is_expected.to be_running
          is_expected.to be_enabled
        end
      end
    end

    describe "Create schema for #{version}." do
      it 'works with no errors' do
        apply_manifest(t.schema_create_pp, catch_failures: true)
      end

      if version != 2.1
        it 'check code is idempotent' do
          expect(apply_manifest(t.schema_create_pp, catch_failures: true).exit_code).to be_zero
        end
      end
    end

    describe "Schema drop type for #{version}." do
      it 'works with no errors' do
        apply_manifest(t.schema_drop_type_pp, catch_failures: true)
      end

      it 'check code is idempotent' do
        expect(apply_manifest(t.schema_drop_type_pp, catch_failures: true).exit_code).to be_zero
      end
    end

    describe "Revoke permissions for #{version}." do
      it 'works with no errors' do
        apply_manifest(t.permissions_revoke_pp, catch_failures: true)
      end

      it 'check code is idempotent' do
        expect(apply_manifest(t.permissions_revoke_pp, catch_failures: true).exit_code).to be_zero
      end
    end

    describe "Drop user for #{version}" do
      it 'works with no errors' do
        apply_manifest(t.schema_drop_user_pp, catch_failures: true)
      end

      it 'check code is idempotent' do
        expect(apply_manifest(t.schema_drop_user_pp, catch_failures: true).exit_code).to be_zero
      end
    end

    describe "Drop index for #{version}" do
      it 'works with no errors' do
        apply_manifest(t.schema_drop_index_pp, catch_failures: true)
      end

      it 'check code is idempotent' do
        expect(apply_manifest(t.schema_drop_index_pp, catch_failures: true).exit_code).to be_zero
      end
    end

    describe "Drop table for #{version}" do
      it 'works with no errors' do
        apply_manifest(t.schema_drop_table_pp, catch_failures: true)
      end

      it 'check code is idempotent' do
        expect(apply_manifest(t.schema_drop_table_pp, catch_failures: true).exit_code).to be_zero
      end
    end

    describe "Drop keyspace for #{version}" do
      it 'works with no errors' do
        apply_manifest(t.schema_drop_keyspace_pp, catch_failures: true)
      end

      it 'check code is idempotent' do
        expect(apply_manifest(t.schema_drop_keyspace_pp, catch_failures: true).exit_code).to be_zero
      end
    end

    describe "Facts Tests for #{version}" do
      it 'works with no errors' do
        apply_manifest(t.facts_testing_pp, catch_failures: true)
      end
    end

    next unless version != 3.0
    describe "Uninstall #{version}." do
      it 'works with no errors' do
        apply_manifest(t.cassandra_uninstall_pp, catch_failures: true)
      end
    end
  end
end
