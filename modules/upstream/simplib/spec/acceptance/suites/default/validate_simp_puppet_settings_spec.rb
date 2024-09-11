require 'spec_helper_acceptance'

test_name 'validate simp puppet_settings fact'

describe 'validate simp puppet_settings fact' do
  let(:puppet_conf) do
    <<-PUPPET_CONF.gsub(%r{^ {6}}, '')
      [main]
        vardir = /opt/puppetlabs/puppet/cache
      [master]
        vardir = /opt/puppetlabs/server/data/puppetserver
    PUPPET_CONF
  end

  hosts.each do |host|
    context "when [main] and [master] have different vardirs in puppet.conf" do
      it 'master.server_datadir should start with the [master] vardir' do
        tmp_dir = create_tmpdir_on(host, 'validate_simp_puppet_settings_spec')
        tmp_puppet_conf_path = "#{tmp_dir}/validate_simp_puppet_settings_spec--puppet.conf"
        tmp_puppet_manifest_path = "#{tmp_dir}/validate_simp_puppet_settings_spec--manifest.pp"
        manifest = <<-MANIFEST.gsub(%r{^ {10}}, '')
          file{ '#{tmp_dir}/master-server_datadir.fact':
            content => fact('puppet_settings.master.server_datadir')
          }
        MANIFEST
        create_remote_file(host, tmp_puppet_conf_path, puppet_conf)
        create_remote_file(host, tmp_puppet_manifest_path, manifest)

        on host, "puppet apply '#{tmp_puppet_manifest_path}' --config '#{tmp_puppet_conf_path}'"
        master_server_datadir = on(host, "cat #{tmp_dir}/master-server_datadir.fact").stdout
        expect(master_server_datadir).to start_with('/opt/puppetlabs/server/data/puppetserver')
      end
    end
  end
end
