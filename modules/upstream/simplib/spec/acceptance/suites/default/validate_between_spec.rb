require 'spec_helper_acceptance'

test_name 'simplib::validate_between function'

describe 'simplib::validate_between function' do
  let(:opts_with_exit_1) do
    {
      :acceptable_exit_codes => [1]
    }
  end

  hosts.each do |server|
    context "when simplib::validate_between called on #{server}" do
      it 'should accept element within range' do
        manifest = <<-EOS
        $var1 = 7
        simplib::validate_between($var1, 0, 60)
        EOS
        apply_manifest_on(server, manifest)
      end

      # bug in the old Puppet 3 function returned false instead of failing
      it 'should reject element outside of range' do
        manifest = <<-EOS
        $var1 = 70
        simplib::validate_between($var1, 0, 60)
        EOS
        apply_manifest_on(server, manifest, opts_with_exit_1)
      end
    end
  end
end
