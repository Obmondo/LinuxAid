require 'spec_helper_acceptance'

test_name 'simplib::validate_array_member function'

describe 'simplib::validate_array_member function' do
  let(:opts_with_exit_1) do
    {
      :acceptable_exit_codes => [1]
    }
  end

  hosts.each do |server|
    context "when simplib::validate_array_member called on #{server}" do
      it 'should accept element that is in array' do
        manifest = <<-EOS
        $var1 = 'foo'
        simplib::validate_array_member($var1, ['foo', 'FOO'])
        EOS
        apply_manifest_on(server, manifest)
      end

      it 'should reject element that is not in array' do
        manifest = <<-EOS
        $var1 = 'foo'
        simplib::validate_array_member($var1, ['bar', 'BAR'])
        EOS
        apply_manifest_on(server, manifest, opts_with_exit_1)
      end
    end
  end
end
