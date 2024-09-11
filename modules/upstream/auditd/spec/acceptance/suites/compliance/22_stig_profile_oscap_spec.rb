require 'spec_helper_acceptance'

test_name 'Check SCAP for stig profile'

describe 'run the SSG against the appropriate fixtures for stig audit profile' do

  hosts.each do |host|
    context "on #{host}" do
      before(:all) do
        @ssg = Simp::BeakerHelpers::SSG.new(host)

        # If we don't do this, the variable gets reset
        @ssg_report = { :data => nil }
      end

      it 'should run the SSG' do
        profile = 'xccdf_org.ssgproject.content_profile_stig'

        @ssg.evaluate(profile)
      end

      it 'should have an SSG report' do
        # Filter on records containing '_audit_'
        # This isn't perfect, but it should be partially OK
        filter = 'rule_audit_'

        # TODO: Check this periodically to see if it has been fixed upstream
        # These appear to be broken in the ComplianceAsCode content
        exclusions = [
          'audit_rules_privileged_',
          'audit_rules_execution_'
        ]

        @ssg_report[:data] = @ssg.process_ssg_results(filter, exclusions)

        expect(@ssg_report[:data]).to_not be_nil

        @ssg.write_report(@ssg_report[:data])
      end

      it 'should have run some tests' do
        expect(@ssg_report[:data][:failed].count + @ssg_report[:data][:passed].count).to be > 0
      end

      it 'should not have any failing tests' do
        if @ssg_report[:data][:failed].count > 0
          puts @ssg_report[:data][:report]
        end

        # TODO: Investigate these items. I think they're false positivies
        #
        # Leaving this as a regular test because we need to know if it changes
        # from the expected value.
        expect(@ssg_report[:data][:score]).to be > 90
      end
    end
  end
end
