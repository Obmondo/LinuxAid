require 'spec_helper_acceptance'
require 'json'

test_name 'Check Inspec for stig profile'

describe 'run inspec against the appropriate fixtures for stig audit profile' do

  profiles_to_validate = ['disa_stig']

  hosts.each do |host|
    profiles_to_validate.each do |profile|
      context "for profile #{profile}" do
        context "on #{host}" do
          before(:all) do
            @inspec = Simp::BeakerHelpers::Inspec.new(host, profile)

            # If we don't do this, the variable gets reset
            @inspec_report = { :data => nil }
          end

          it 'should run inspec' do
            @inspec.run
          end

          it 'should have an inspec report' do
            @inspec_report[:data] = @inspec.process_inspec_results

            expect(@inspec_report[:data]).to_not be_nil

            @inspec.write_report(@inspec_report[:data])
          end

          it 'should have run some tests' do
            expect(@inspec_report[:data][:failed] + @inspec_report[:data][:passed]).to be > 0
          end

          it 'should not have any failing tests' do
            # 1 test erroneously fails
            # - 'The system must send rsyslog output to a log aggregation server':
            #    - inspec_profiles/profiles/disa_stig-el7-baseline/controls/V-72209.rb
            #    - inspec should skip, as rsyslog is not setup
            if @inspec_report[:data][:failed] > 0
              puts @inspec_report[:data][:global][:failed].join("\n")
              puts @inspec_report[:data][:report]
            end

            expect(@inspec_report[:data][:score] ).to eq(100)
          end
        end
      end
    end
  end
end
