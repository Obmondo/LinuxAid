require 'spec_helper'

# Remove v1 data. Can be removed once compliance_markup::debug::enabled_sce_versions is implemented
v1_profiles = './spec/fixtures/modules/compliance_markup/data/compliance_profiles'
FileUtils.rm_rf(v1_profiles) if File.directory?(v1_profiles)

# This is the class that needs to be added to the catalog last to make the
# reporting work.
describe 'compliance_markup', type: :class do

  compliance_profiles = [
    'disa_stig',
    'nist_800_53:rev4'
  ]

  # A list of classes that we expect to be included for compliance
  #
  # This needs to be well defined since we can also manipulate defined type
  # defaults
  expected_classes = [
    'auditd'
  ]

  allowed_failures = {
    'documented_missing_parameters' => [
    ] + expected_classes.map{|c| Regexp.new("^(?!#{c}(::.*)?)")},
    'documented_missing_resources' => [
    ] + expected_classes.map{|c| Regexp.new("^(?!#{c}(::.*)?)")}
  }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      compliance_profiles.each do |target_profile|
        context "with compliance profile '#{target_profile}'" do
          let(:facts){
            if ! os_facts[:auditd_major_version]
               if os_facts[:os][:release][:major] < '8'
                 os_facts[:auditd_major_version] = '2'
               else
                 os_facts[:auditd_major_version] = '3'
               end
            end

            os_facts.merge({
              :target_compliance_profile => target_profile
            })
          }

          let(:pre_condition) {%(
            #{expected_classes.map{|c| %{include #{c}}}.join("\n")}
          )}

          let(:hieradata){ 'compliance-engine' }

          it { is_expected.to compile }

          let(:compliance_report) {
            @compliance_report ||= JSON.load(
                catalogue.resource("File[#{facts[:puppet_vardir]}/compliance_report.json]")[:content]
              )

            @compliance_report
          }

          let(:compliance_profile_data) {
            @compliance_profile_data ||= compliance_report['compliance_profiles'][target_profile]

            @compliance_profile_data
          }

          it 'should have a compliance profile report' do
            expect(compliance_profile_data).to_not be_nil
          end

          it 'should have a 100% compliant report' do
            expect(compliance_profile_data['summary']['percent_compliant']).to eq(100)
          end

          # The list of report sections that should not exist and if they do
          # exist, we need to know what is wrong so that we can fix them
          report_validators = [
            # This should *always* be empty on enforcement
            'non_compliant',
            # If something is set here, either the upstream API changed or you
            # have a typo in your data
            'documented_missing_parameters',
            # If something is set here, you have included enforcement data that
            # you are not testing so you either need to remove it from your
            # profile or you need to add the class/defined type for validation
            #
            # Unless this is a completely comprehensive data profile, with all
            # classes included, this report may be useless and is disabled by
            # default.
            #
            'documented_missing_resources'
          ]

          report_validators.each do |report_section|
            it "should have no issues with the '#{report_section}' report" do
              if compliance_profile_data[report_section]
                # This just gets us a good print out of what went wrong
                  compliance_profile_data[report_section].delete_if{ |item|
                    rm = false

                    Array(allowed_failures[report_section]).each do |allowed|
                      if allowed.is_a?(Regexp)
                        if allowed.match?(item)
                          rm = true
                          break
                        end
                      else
                        rm = (allowed == item)
                      end
                    end

                    rm
                  }

                expect(compliance_profile_data[report_section]).to eq([])
              end
            end
          end
        end
      end
    end
  end
end
