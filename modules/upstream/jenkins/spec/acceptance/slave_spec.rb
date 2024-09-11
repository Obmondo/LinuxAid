require 'spec_helper_acceptance'

describe 'jenkins::slave class' do
  include_context 'jenkins'

  context 'default parameters' do
    pp = <<-EOS
      include ::jenkins::slave
    EOS

    apply2(pp)

    if $systemd
      describe file('/etc/systemd/system/jenkins-slave.service') do
        it { is_expected.to be_file }
        it { is_expected.to contain 'ExecStart=/home/jenkins-slave/jenkins-slave-run' }
      end
      describe file('/etc/init.d/jenkins-slave') do
        it { is_expected.not_to exist }
      end
      describe service('jenkins-slave') do
        it { is_expected.to be_running.under('systemd') }
      end
    else
      describe file('/etc/systemd/system/jenkins-slave.service') do
        it { is_expected.not_to exist }
      end
      describe file('/etc/init.d/jenkins-slave') do
        it { is_expected.to be_file }
        it { is_expected.to be_mode 755 }
      end
    end

    describe file("#{$sysconfdir}/jenkins-slave") do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 600 }
    end

    describe file('/home/jenkins-slave/swarm-client-2.2-jar-with-dependencies.jar') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
    end

    describe service('jenkins-slave') do
      it { is_expected.to be_running }
      it { is_expected.to be_enabled }
    end
  end # default parameters

  context 'parameters' do
    before(:all) do
      pp = <<-EOS
        # attempt to make the swarm client the only running 'java' process
        service { jenkins: ensure => 'stopped' }
      EOS

      apply_manifest(pp)
    end

    context 'ui_user/ui_pass' do
      pp = <<-EOS
        class { ::jenkins::slave:
          ui_user => 'imauser',
          ui_pass => 'imapass',
        }
      EOS

      apply2(pp)

      describe process('java') do
        its(:user) { is_expected.to eq 'jenkins-slave' }
        its(:args) { is_expected.to match %r{-username imauser} }
        its(:args) { is_expected.to match %r{-passwordEnvVariable JENKINS_PASSWORD} }
        its(:args) { is_expected.not_to match %r{imapass} }
      end
    end # username/password

    context 'disable_clients_unique_id' do
      context 'true' do
        pp = <<-EOS
          class { ::jenkins::slave:
            disable_clients_unique_id => true,
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-disableClientsUniqueId} }
        end
      end # true

      context 'false' do
        pp = <<-EOS
          class { ::jenkins::slave:
            disable_clients_unique_id => false,
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.not_to match %r{-disableClientsUniqueId} }
        end
      end # false
    end # disable_clients_unique_id

    context 'disable_ssl_verification' do
      context 'true' do
        pp = <<-EOS
          class { ::jenkins::slave:
            disable_ssl_verification => true,
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-disableSslVerification} }
        end
      end # true

      context 'false' do
        pp = <<-EOS
          class { ::jenkins::slave:
            disable_ssl_verification => false,
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.not_to match %r{-disableSslVerification} }
        end
      end # false
    end # disable_ssl_verification

    context 'delete_existing_clients' do
      context 'true' do
        pp = <<-EOS
          class { ::jenkins::slave:
            delete_existing_clients => true,
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-deleteExistingClients} }
        end
      end # true

      context 'false' do
        pp = <<-EOS
          class { ::jenkins::slave:
            delete_existing_clients => false,
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.not_to match %r{-deleteExistingClients} }
        end
      end # false
    end # delete_existing_clients

    context 'labels' do
      context 'single label in string' do
        pp = <<-EOS
          class { ::jenkins::slave:
            labels => 'foo',
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-labels foo} }
        end
      end

      context 'multiple labels in string' do
        pp = <<-EOS
          class { ::jenkins::slave:
            labels => 'foo bar baz',
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-labels foo bar baz} }
        end
      end

      context 'multiple labels in array' do
        pp = <<-EOS
          class { ::jenkins::slave:
            labels => ['foo', 'bar', 'baz'],
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-labels foo bar baz} }
        end
      end
    end # labels

    context 'tool_locations' do
      tool_locations = 'Python-2.7:/usr/bin/python2.7 Java-1.8:/usr/bin/java'

      context tool_locations do
        pp = <<-EOS
          class { ::jenkins::slave:
            tool_locations => '#{tool_locations}',
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{--toolLocation Python-2\.7=/usr/bin/python2\.7} }
          its(:args) { is_expected.to match %r{--toolLocation Java-1\.8=/usr/bin/java} }
        end
      end
    end # tool_locations

    context 'tunnel' do
      tunnel = 'localhost:9000'

      context tunnel do
        pp = <<-EOS
          class { ::jenkins::slave:
            tunnel => '#{tunnel}',
          }
        EOS

        apply2(pp)

        describe process('java') do
          its(:user) { is_expected.to eq 'jenkins-slave' }
          its(:args) { is_expected.to match %r{-tunnel localhost:9000} }
        end
      end
    end # tunnel
  end # parameters
end
