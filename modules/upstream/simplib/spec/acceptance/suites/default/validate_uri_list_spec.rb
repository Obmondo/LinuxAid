require 'spec_helper_acceptance'

test_name 'simplib::validate_uri_list function'

describe 'simplib::validate_uri_list function' do
  let(:opts_with_exit_1) do
    {
      :acceptable_exit_codes => [1]
    }
  end

  hosts.each do |server|
    context "when simplib::validate_uri_list called on #{server}" do
      it 'should accept valid URIs' do
        manifest = <<-EOS
        $var1 = simplib::validate_uri_list('https://1.2.3.4:56', ['http','https'])
        EOS
        apply_manifest_on(server, manifest)
      end

      it 'should reject invalid URIs' do
        manifest = <<-EOS
        $var1 = simplib::validate_uri_list('ldap://1.2.3.4:56', ['http','https'])
        EOS
        apply_manifest_on(server, manifest, opts_with_exit_1)
      end
    end
  end
end
