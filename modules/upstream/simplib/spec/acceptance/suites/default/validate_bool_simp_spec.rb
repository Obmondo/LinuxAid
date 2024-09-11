require 'spec_helper_acceptance'

test_name 'simplib::validate_bool function'

describe 'simplib::validate_bool function' do
  let(:opts_with_exit_1) do
    {
      :acceptable_exit_codes => [1]
    }
  end

  hosts.each do |server|
    context "when simplib::validate_bool called on #{server}" do
      it 'should accept valid bool equivalent' do
        manifest = <<-EOS
        $var1 = "true"
        simplib::validate_bool($var1)
        EOS
        apply_manifest_on(server, manifest)
      end

      it 'should reject invalid bool equivalent' do
        manifest = <<-EOS
        $var1 = "True"
        simplib::validate_bool($var1)
        EOS
        apply_manifest_on(server, manifest, opts_with_exit_1)
      end
    end
  end
end
