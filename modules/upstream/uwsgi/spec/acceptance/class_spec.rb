require 'spec_helper_acceptance'

describe 'uwsgi class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'uwsgi':
        setup_python => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('uwsgi') do
      it { is_expected.to be_installed.by('pip') }
    end

    describe file('/etc/uwsgi/vassals.d') do
      it { should be_directory }
      it { should be_owned_by 'uwsgi' }
    end

    describe file('/etc/uwsgi/plugins') do
      it { should be_directory }
      it { should be_owned_by 'uwsgi' }
    end

    describe file('/var/run/uwsgi/uwsgi.socket') do
      it { should be_socket }
    end

    describe user('uwsgi') do
      it { should exist }
      it { should_not have_login_shell "/bin/bash" }
    end

    describe file('/etc/uwsgi/emperor.ini') do
      it { should be_file }
      it { should be_owned_by 'uwsgi' }
    end

    describe service('uwsgi') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
