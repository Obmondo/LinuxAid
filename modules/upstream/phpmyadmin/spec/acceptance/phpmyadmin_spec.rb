require 'spec_helper_acceptance'

describe 'phpmyadmin class' do
  describe 'running puppet code' do
    it 'should work without errors' do
      pp = 'class { \'phpmyadmin\': }'

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it 'should create config from template correctly'
  end
end
