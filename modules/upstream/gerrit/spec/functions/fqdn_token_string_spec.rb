require 'spec_helper'

describe 'fqdn_token_string', :type => :puppet_function do
  let(:facts) { { :fqdn => 'my.test.com' } }

  it 'should succeed' do
    subject.call([14])     == 'mScmLr+OfBFQVP'
    subject.call([14, 50]) == 'Y24Q0xJOyNyi72'
  end

  it 'should fail' do
    expect { subject.call().should raise_error(Puppet::ParseError) }
  end
end

# vim: ts=2 sw=2 sts=2 et :
