require 'spec_helper_acceptance'

describe 'ipset class' do
  context 'default parameters' do
    it 'works idempotently with no errors' do
      pp = 'include ipset'
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe service('ipset') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end
  context 'with a basic ipset' do
    it 'works idempotently with no errors' do
      pp = <<-EOS
      include ipset
      ipset::set{'basic-set':
        set  => ['10.0.0.1', '10.0.0.2', '10.0.0.42'],
        type => 'hash:net',
        }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('ipset list basic-set') do
      its(:stdout) { is_expected.to match %r{.*basic-set.*Type: hash:net.*10\.0\.0\.2.*}m }
    end
  end

  context 'can delete ipsets' do
    it 'works even here idempotently with no errors' do
      pp = <<-EOS
      include ipset
      ipset::set{'basic-set':
        ensure => 'absent',
        set  => ['10.0.0.1', '10.0.0.2', '10.0.0.42'],
        type => 'hash:net',
      }
      EOS
      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    describe command('ipset list') do
      # its(:stdout) { is_expected.to match %r{.*The set with the given name does not exist.*} }
      its(:stdout) { is_expected.to match '' }
    end
  end
end
