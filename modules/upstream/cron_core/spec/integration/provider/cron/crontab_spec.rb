require 'spec_helper'
require 'puppet/file_bucket/dipper'
require 'puppet_spec/compiler'

describe Puppet::Type.type(:cron).provider(:crontab), unless: Puppet.features.microsoft_windows? do
  include PuppetSpec::Files
  include PuppetSpec::Compiler

  before :each do
    Puppet::Type.type(:cron).stubs(:defaultprovider).returns described_class
    described_class.stubs(:suitable?).returns true
    Puppet::FileBucket::Dipper.any_instance.stubs(:backup) # rubocop:disable RSpec/AnyInstance

    # I don't want to execute anything
    described_class.stubs(:filetype).returns Puppet::Util::FileType::FileTypeFlat
    described_class.stubs(:default_target).returns crontab_user1

    # I don't want to stub Time.now to get a static header because I don't know
    # where Time.now is used elsewhere, so just go with a very simple header
    described_class.stubs(:header).returns "# HEADER: some simple\n# HEADER: header\n"
    FileUtils.cp(my_fixture('crontab_user1'), crontab_user1)
    FileUtils.cp(my_fixture('crontab_user2'), crontab_user2)
  end

  after :each do
    described_class.clear
  end

  let :crontab_user1 do
    tmpfile('cron_integration_specs')
  end

  let :crontab_user2 do
    tmpfile('cron_integration_specs')
  end

  def expect_output(fixture_name)
    expect(File.read(crontab_user1)).to eq(File.read(my_fixture(fixture_name)))
  end

  describe 'when managing a cron entry' do
    it 'is able to purge unmanaged entries' do
      apply_with_error_check(<<-MANIFEST)
      cron {
        'only managed entry':
          ensure      => 'present',
          command     => '/bin/true',
          target      => '#{crontab_user1}',
      }
      resources { 'cron': purge => 'true' }
      MANIFEST
      expect_output('purged')
    end

    describe 'with ensure absent' do
      it 'does nothing if entry already absent' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'no_such_entry':
            ensure => 'absent',
            target => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('crontab_user1')
      end

      it 'removes the resource from crontab if present' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'My daily failure':
            ensure => 'absent',
            target => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('remove_named_resource')
      end

      it 'removes a matching cronentry if present' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'no_such_named_resource_in_crontab':
            ensure   => absent,
            minute   => [ '17-19', '22' ],
            hour     => [ '0-23/2' ],
            weekday  => 'Tue',
            command  => '/bin/unnamed_regular_command',
            target   => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('remove_unnamed_resource')
      end
    end

    describe 'with ensure present' do
      context 'and no command specified' do
        it 'works if the resource is already present' do
          apply_with_error_check(<<-MANIFEST)
          cron {
            'My daily failure':
              special => 'daily',
              target  => '#{crontab_user1}',
          }
          MANIFEST
          expect_output('crontab_user1')
        end
        it 'fails if the resource needs creating' do
          manifest = <<-MANIFEST
          cron {
            'Entirely new resource':
              special => 'daily',
              target  => '#{crontab_user1}',
          }
          MANIFEST
          apply_compiled_manifest(manifest) do |res|
            if res.ref == 'Cron[Entirely new resource]'
              res.expects(:err).with(regexp_matches(%r{no command}))
            else
              res.expects(:err).never
            end
          end
        end
      end

      it 'does nothing if entry already present' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'My daily failure':
            special => 'daily',
            command => '/bin/false',
            target  => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('crontab_user1')
      end

      it "works correctly when managing 'target' but not 'user'" do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'My weekly failure':
            special => 'weekly',
            command => '/bin/false',
            target  => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('crontab_user3')
      end

      it 'does nothing if a matching entry already present' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'no_such_named_resource_in_crontab':
            ensure   => present,
            minute   => [ '17-19', '22' ],
            hour     => [ '0-23/2' ],
            command  => '/bin/unnamed_regular_command',
            target   => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('crontab_user1')
      end

      it 'adds a new normal entry if currently absent' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'new entry':
            ensure      => present,
            minute      => '12',
            weekday     => 'Tue',
            command     => '/bin/new',
            environment => [
              'MAILTO=""',
              'SHELL=/bin/bash'
            ],
            target      => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('create_normal_entry')
      end

      it 'adds a new special entry if currently absent' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'new special entry':
            ensure      => present,
            special     => 'reboot',
            command     => 'echo "Booted" 1>&2',
            environment => 'MAILTO=bob@company.com',
            target      => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('create_special_entry')
      end

      it 'changes existing entry if out of sync' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'Monthly job':
            ensure      => present,
            special     => 'monthly',
            #minute => ['22'],
            command     => '/usr/bin/monthly',
            environment => [],
            target      => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('modify_entry')
      end
      it 'changes a special schedule to numeric if requested' do
        apply_with_error_check(<<-MANIFEST)
        cron {
          'My daily failure':
            special     => 'absent',
            command     => '/bin/false',
            target      => '#{crontab_user1}',
        }
        MANIFEST
        expect_output('unspecialized')
      end
      it 'does not try to move an entry from one file to another' do
        # force the parsedfile provider to also parse user1's crontab
        apply_with_error_check(<<-MANIFEST)
        cron {
          'foo':
            ensure => absent,
            target => '#{crontab_user1}';
          'My daily failure':
            special      => 'daily',
            command      => "/bin/false",
            target       => '#{crontab_user2}',
        }
        MANIFEST
        expect(File.read(crontab_user1)).to eq(File.read(my_fixture('moved_cronjob_input1')))
        expect(File.read(crontab_user2)).to eq(File.read(my_fixture('moved_cronjob_input2')))
      end
    end
  end
end
