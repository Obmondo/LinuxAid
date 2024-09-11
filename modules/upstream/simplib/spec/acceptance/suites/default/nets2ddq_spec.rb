require 'spec_helper_acceptance'

test_name 'simplib::nets2ddq function'

describe 'simplib::nets2ddq function' do

  hosts.each do |server|
    context "when simplib::nets2ddq called on #{server}" do
      let (:manifest) {
        <<-EOS
        $var1 = [ '10.0.1.0/24', '10.0.2.0/255.255.255.0', '10.0.3.25', 'myhost' ]
        $var2 = simplib::nets2ddq($var1)

        simplib::inspect('var2')
        EOS
      }

      it 'should return a converted array' do
        results = apply_manifest_on(server, manifest)

        expected_regex = %r{\["10.0.1.0\/255.255.255.0","10.0.2.0\/255.255.255.0","10.0.3.25","myhost"\]}
        expect(results.output).to match(expected_regex)
      end
    end
  end
end
