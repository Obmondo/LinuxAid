#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::simp_version' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts){ os_facts }

      let(:simp_version_path) {
        if os_facts[:kernel].casecmp?('windows')
          'C:\ProgramData\SIMP\simp.version'
        else
          '/etc/simp/simp.version'
        end
      }

      context 'a valid version exists in simp.version' do
        it 'should return the version with whitespace retained' do
          File.expects(:read).with(simp_version_path).returns(" 6.4.0-0\n")
          File.stubs(:readable?).with(simp_version_path).returns(true)
          File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

          is_expected.to run.and_return(" 6.4.0-0\n")
        end

        it "should return the version with 'simp-' stripped" do
          File.stubs(:readable?).with(simp_version_path).returns(true)
          File.stubs(:read).with(simp_version_path).returns("simp-5.4.0-0\n")
          File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

          is_expected.to run.and_return("5.4.0-0\n")
        end

        it 'should return the version with whitespace stripped when stripping is enabled' do
          File.stubs(:readable?).with(simp_version_path).returns(true)
          File.stubs(:read).with(simp_version_path).returns("6.4.0-0\n")
          File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

          is_expected.to run.with_params(true).and_return('6.4.0-0')
        end
      end

      context 'simp.version is empty' do
        it 'should return unknown' do
          File.stubs(:read).with(simp_version_path).returns("")
          File.stubs(:readable?).with(simp_version_path).returns(true)
          File.stubs(:read).with(regexp_matches(/metadata.json/), {:encoding => "utf-8"}).returns('')

          is_expected.to run.and_return("unknown\n")
        end
      end

      unless os_facts[:kernel].casecmp?('windows')
        context 'simp.version does not exist' do
          let(:rpm_query) do
            %q{PATH='/usr/local/bin:/usr/bin:/bin' rpm -q --qf '%{VERSION}-%{RELEASE}\n' simp 2>/dev/null}
          end

          context 'rpm query succeeds' do
            it 'should return the version with whitespace retained' do
              File.stubs(:readable?).with(simp_version_path).returns(false)
              Puppet::Util::Execution.stubs(:execute).with(rpm_query, {:failonfail => true}).returns("6.4.0-0\n")

              is_expected.to run.and_return("6.4.0-0\n")
            end

            it 'should return the version with whitespace stripped when stripping is enabled' do
              File.stubs(:readable?).with(simp_version_path).returns(false)
              Puppet::Util::Execution.stubs(:execute).with(rpm_query, {:failonfail => true}).returns("6.4.0-0\n")

              is_expected.to run.with_params(true).and_return('6.4.0-0')
            end
          end

          context 'rpm query fails' do
            it 'should return unknown' do
              File.stubs(:readable?).with(simp_version_path).returns(false)
              Puppet::Util::Execution.stubs(:execute).with(rpm_query, {:failonfail => true}).raises(Puppet::ExecutionFailure, "Failed")

              is_expected.to run.and_return("unknown\n")
            end
          end
        end
      end
    end
  end
end
