require 'spec_helper_acceptance'

test_name 'simplib::parse_hosts function'

describe 'simplib::parse_hosts function' do

  hosts.each do |server|
    context "when simplib::parse_hosts called on #{server}" do
      let (:manifest) {
        <<-EOS
        $var1 = simplib::parse_hosts(['my.example.net:900', 'my.example.net:700'])

        simplib::inspect('var1', 'oneline_json')
        EOS
      }

      it 'should transform the host list' do
        results = apply_manifest_on(server, manifest)

        expected_content = %q({"my.example.net":{"ports":\["700","900"\],"protocols":{}}})
        expect(results.output).to match(
          %r(Notice: Type => Hash Content => #{expected_content})
        )
      end
    end
  end
end
