require 'spec_helper_acceptance'

test_name 'prelink fact'

describe 'prelink fact' do
  let (:manifest) {
    <<-EOS
      $prelink_value = $facts['prelink']
      simplib::inspect('prelink_value', 'oneline_json')
    EOS
  }

  hosts.each do |server|
    context 'prepare clean environment' do
      it 'removes prelink when installed' do
        installed =  check_for_package(server, 'prelink')
        if (installed)
          on(server, "sed -i '/PRELINKING=yes/ c\\PRELINKING=no' /etc/sysconfig/prelink")
          # remove prelinking, if appropriate, before uninstalling
          on(server, '/etc/cron.daily/prelink')
          server.uninstall_package('prelink')
        end
      end
    end

    context 'when prelink is not installed' do
      it 'prelink fact should be nil' do
        results = apply_manifest_on(server, manifest)
        expect(results.output).to match(/Notice: Type => NilClass Content => null/)
        results = on(server, 'puppet facts')
        expect(results.output).to_not match(/"prelink": {/)
      end
    end

    if server.host_hash[:roles].include?('prelink')
      context 'when prelink is installed but disabled' do
        it 'prelink fact should report prelink as disabled' do
          server.install_package('prelink')
          # prelinking is enabled by default on el6
          on(server, "sed -i '/PRELINKING=yes/ c\\PRELINKING=no' /etc/sysconfig/prelink")

          results = apply_manifest_on(server, manifest)
          expect(results.output).to match(/Notice: Type => Hash Content => {"enabled":false}/)
          results = on(server, 'puppet facts')
          expect(results.output).to match(/"prelink": {/)
        end
      end

      context 'when prelink is installed and enabled' do
        it 'prelink fact should report prelink as enabled' do
          on(server, "sed -i '/PRELINKING=no/ c\\PRELINKING=yes' /etc/sysconfig/prelink")

          results = apply_manifest_on(server, manifest)
          expect(results.output).to match(/Notice: Type => Hash Content => {"enabled":true}/)
          results = on(server, 'puppet facts')
          expect(results.output).to match(/"prelink": {/)
        end
      end
    end
  end
end
