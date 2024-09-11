require 'spec_helper_acceptance'

test_name 'simplib::validate_port function'

describe 'validate_port function' do
  let(:opts_with_exit_1) do
    {
      :acceptable_exit_codes => [1]
    }
  end

  hosts.each do |server|
    context "when simplib::validate_port called on #{server}" do
      it 'should accept valid ports' do
        manifest = <<-EOS
        $var1 = simplib::validate_port(20)
        EOS
        apply_manifest_on(server, manifest)
      end

      it 'should reject invalid ports' do
        manifest = <<-EOS
        $var1 = simplib::validate_port('65535')
        EOS
        apply_manifest_on(server, manifest, opts_with_exit_1)
      end
    end
  end
end
