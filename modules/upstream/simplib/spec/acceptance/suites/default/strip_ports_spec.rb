require 'spec_helper_acceptance'

test_name 'simplib::strip_ports function'

describe 'simplib::strip_ports function' do

  hosts.each do |server|
    context "when simplib::strip_ports called on #{server}" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::strip_ports(['my.example.net:900', 'my.example.net:700'])

        simplib::inspect('var1', 'oneline_json')
        EOS
      }

      it 'should transform the host list' do
        results = apply_manifest_on(server, manifest)

        expect(results.output).to match(
          %r(Notice: Type => Array Content => \["my.example.net"\])
        )
      end
    end
  end
end
