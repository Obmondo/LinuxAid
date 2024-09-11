require 'spec_helper_acceptance'

test_name 'overall fact sanity'

describe 'running facts' do
  hosts.each do |host|
    context "on #{host}" do
      it do
        result = on(host, 'puppet facts').output.strip.lines

        expect(result.grep(/Error/).grep(/Facter/)).to be_empty
      end
    end
  end
end
