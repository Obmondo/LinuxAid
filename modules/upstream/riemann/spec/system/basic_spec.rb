require 'spec_helper_system'

describe 'basic tests:' do
  it 'my class should work with no errors' do
    pp = <<-EOS
      class { 'riemann': }
    EOS

    # Run it twice and test for idempotency
    puppet_apply(pp) do |r|
      r.exit_code.should == 2
    end
  end
end
