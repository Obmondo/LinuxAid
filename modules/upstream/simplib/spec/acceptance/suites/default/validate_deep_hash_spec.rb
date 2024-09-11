require 'spec_helper_acceptance'

test_name 'simplib::validate_deep_hash function'

describe 'simplib::validate_deep_hash function' do
  let(:opts_with_exit_1) do
    {
      :acceptable_exit_codes => [1]
    }
  end

  hosts.each do |server|
    context "when simplib::validate_deep_hash called on #{server}" do
      it 'should accept valid hash' do
        manifest = <<-EOS
        $var1 = { 'server' => 'foo.bar.com' }
        simplib::validate_deep_hash({ 'server' => 'bar.com$' }, $var1)
        EOS
        apply_manifest_on(server, manifest)
      end

      it 'should reject invalid hash' do
        manifest = <<-EOS
        $var1 = { 'server' => 'foo.baz.com' }
        simplib::validate_deep_hash({ 'server' => 'bar.com$' }, $var1)
        EOS
        apply_manifest_on(server, manifest, opts_with_exit_1)
      end
    end
  end
end
