require 'spec_helper'

describe 'thinlinc::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      # Without an [Install] section `systemctl enable` is a no-op and the
      # services stay down after a reboot until Puppet next runs.
      %w[vsmserver vsmagent tlwebadm tlwebaccess].each do |service|
        it "makes #{service} start at boot" do
          unit = catalogue.resource('file', "/etc/systemd/system/#{service}.service")

          expect(unit[:content]).to match(%r{^\[Install\]$})
          expect(unit[:content]).to match(%r{^WantedBy=multi-user\.target$})
          expect(catalogue.resource('service', service)[:enable]).to eq(true)
        end
      end

      it 'describes each unit by what it is' do
        content = catalogue.resource('file', '/etc/systemd/system/vsmagent.service')[:content]

        expect(content).to match(%r{^Description=ThinLinc VSM Agent$})
      end
    end
  end
end
