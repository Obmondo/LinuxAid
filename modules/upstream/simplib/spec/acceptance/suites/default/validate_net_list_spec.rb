require 'spec_helper_acceptance'

test_name 'simplib::validate_net_list function'

describe 'simplib::validate_net_list function' do
  let(:opts_with_exit_1) do
    {
      :acceptable_exit_codes => [1]
    }
  end

  hosts.each do |server|
    context "when simplib::validate_net_list called on #{server}" do
      it 'should accept valid netlists' do
        manifest = <<-EOS
        $var1 = ['20.20.20.0/24','4.3.2.1','6.4.3.1:800']
        simplib::validate_net_list($var1)
        EOS
        apply_manifest_on(server, manifest)
      end

      it 'should reject invalid netlists' do
        manifest = <<-EOS
        $var1 = 'bad stuff'
        simplib::validate_net_list($var1)
        EOS
        apply_manifest_on(server, manifest, opts_with_exit_1)
      end
    end
  end
end
