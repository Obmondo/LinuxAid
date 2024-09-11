require 'spec_helper_acceptance'

describe 'curator class' do
  context 'defaults' do
    if fact('osfamily') == 'RedHat'
      it 'adds epel to and installs pip' do
        pp = "class { 'epel': }"
        apply_manifest(pp, catch_failures: true)
        shell('yum -y install python-pip')
        # Hack for EL7-based machines -- https://tickets.puppetlabs.com/browse/PUP-3829
        if fact('operatingsystemmajrelease').to_i > 6
          shell('ln -s /bin/pip /bin/pip-python')
        end
      end
    end

    if fact('osfamily') == 'Debian'
      it 'installs pip' do
        shell('apt-get -y install python-pip')
      end
    end

    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'curator': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('which curator') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
