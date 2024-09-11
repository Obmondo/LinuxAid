require 'spec_helper_acceptance'

test_name 'ipa fact'

def skip_fips(host)
  if fips_enabled(host) && host.host_hash[:roles].include?('no_fips')
    return true
  else
    return false
  end
end

describe 'ipa fact' do
  let (:manifest) {
    <<-EOS
      $ipa_value = $facts['ipa']
      simplib::inspect('ipa_value', 'oneline_json')
    EOS
  }

  admin_password = '@dm1n=P@ssw0r!'
  ipa_domain = 'test.case'
  ipa_realm = ipa_domain.upcase

  hosts.each do |host|
    it 'should be running haveged for entropy' do
      if skip_fips(host)
        pending("#{host} does not work in FIPS mode")
        expect(false).to eq true

        next
      else
        # IPA requires entropy, so use haveged service
        on(host, 'puppet resource package epel-release ensure=present')
        on(host, 'puppet resource package haveged ensure=present')
        on(host, 'puppet resource service haveged ensure=running enable=true')

        # Install the IPA client on all hosts
        on(host, 'puppet resource package ipa-client ensure=present')

        # Admintools for EL6
        on(host, 'puppet resource package ipa-admintools ensure=present', :accept_all_exit_codes => true)

        # Ensure that the hostname is set to the FQDN
        hostname = fact_on(host, 'fqdn')
        if host.host_hash['platform'] =~ /el-7/
          on(host, "hostnamectl set-hostname #{hostname}")
        else
          on(host, "hostname #{hostname}")
          create_remote_file(host, '/etc/hostname', "#{hostname}\n")
          on(host, "sed -i '/HOSTNAME/d' /etc/sysconfig/network")
          on(host, "echo HOSTNAME=#{hostname} >> /etc/sysconfig/network")
        end

        # DBus may need to be restarted after updating, and a reboot is the only way
        host.reboot
      end
    end
  end

  hosts_with_role(hosts, 'server').each do |server|
    next if skip_fips(server)

    context 'when IPA is not installed' do
      it 'ipa fact should be nil' do
        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(/Notice: Type => NilClass Content => null/)

        results = JSON.load(on(server, 'puppet facts').output)

        expect(results['values']['ipa']).to be_nil
      end
    end

    context 'when IPA is installed, but host has not yet joined IPA domain' do
      it 'ipa fact should be nil because /etc/ipa/default.conf does not exist' do
        upgrade_package(server, 'nss')
        install_package(server, 'ipa-server')
        server.reboot # WORKAROUND: https://bugzilla.redhat.com/show_bug.cgi?id=1504688

        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(/Notice: Type => NilClass Content => null/)

        results = JSON.load(on(server, 'puppet facts').output)

        expect(results['values']['ipa']).to be_nil
      end
    end

    context 'when IPA is installed and host has joined IPA domain' do
      let(:ipa_domain) { "#{server.name.downcase}.example.com" }
      it 'ipa fact should contain domain and IPA server' do
        # ipa-server-install installs both the IPA server and client.
        # The fact uses the client env.
        fqdn = fact_on(server, 'fqdn')

        cmd = [
          'umask 0022 &&',
          'ipa-server-install',
          # IPA realm and domain do not have to match hostname
          "--domain #{ipa_domain}",
          "--realm #{ipa_realm}",
          "--hostname #{fqdn}",
          '--ds-password "d1r3ct0ry=P@ssw0r!"',
          "--admin-password '#{admin_password}'",
          '--unattended'
        ]
        puts "\e[1;34m>>>>> The next step takes a very long time ... Please be patient! \e[0m"
        on(server, cmd.join(' '))
        on(server, 'ipactl status')

        # We only care about this data
        expect(apply_manifest_on(server, manifest).output).to match(/Hash Content => {"/)

        results = JSON.load(on(server, 'puppet facts').output)

        expect(results['values']['ipa']).to_not be_nil
        expect(results['values']['ipa']['connected']).to eq true
        expect(results['values']['ipa']['server']).to eq fqdn
        expect(results['values']['ipa']['domain']).to eq ipa_domain
        expect(results['values']['ipa']['realm']).to eq ipa_realm
      end

      it 'ipa fact should have unknown status when connection to IPA server is down' do
        # stop IPA server
        on(server, 'ipactl stop')

        results = JSON.load(on(server, 'puppet facts').output)

        expect(results['values']['ipa']).to_not be_nil
        expect(results['values']['ipa']['connected']).to eq false
      end

      it 'should restart the IPA server for further tests' do
        on(server, 'ipactl start')
      end
    end
  end

  hosts_with_role(hosts, 'client').each do |client|
    next if skip_fips(client)

    context 'as an IPA client' do

      context 'prior to registration' do
        it 'should not have an IPA fact' do
          results = JSON.load(on(client, 'puppet facts').output)

          expect(results['values']['ipa']).to be_nil
        end
      end

      context 'after registration' do
        let(:ipa_server) {
          fact_on(hosts_with_role(hosts, 'server').first, 'fqdn')
        }

        it 'should register with the IPA server' do
          ipa_command = [
            # Unattended installation
            'ipa-client-install -U',
            # IPA directory domain
            "--domain=#{ipa_domain}",
            # IPA server to use
            "--server=#{ipa_server}",
            # Only point at this server and don't use SRV
            '--fixed-primary',
            # IPA krb5 realm
            "--realm=#{ipa_realm}",
            # Krb5 principal name to use
            '--principal=admin',
            # Admin password
            "--password='#{admin_password}'",
            # Don't update using authconfig
            '--noac'
          ].join(' ')

          on(client, ipa_command)
        end

        it 'should have the IPA fact populated' do
          results = JSON.load(on(client, 'puppet facts').output)

          expect(results['values']['ipa']).to_not be_nil
          expect(results['values']['ipa']['connected']).to eq true
          expect(results['values']['ipa']['server']).to eq ipa_server
          expect(results['values']['ipa']['domain']).to eq ipa_domain
          expect(results['values']['ipa']['realm']).to eq ipa_realm
        end

        it 'ipa fact should have unknown status when connection to IPA server is down' do
          # stop IPA server
          hosts_with_role(hosts, 'server').each do |server|
            on(server, 'ipactl stop')
          end

          results = JSON.load(on(client, 'puppet facts').output)

          expect(results['values']['ipa']).to_not be_nil
          expect(results['values']['ipa']['connected']).to eq false
        end

        it 'should restart the IPA server for further tests' do
          hosts_with_role(hosts, 'server').each do |server|
            on(server, 'ipactl start')
          end
        end
      end
    end
  end
end
