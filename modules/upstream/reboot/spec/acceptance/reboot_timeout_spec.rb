require 'spec_helper_acceptance'

describe 'Custom Timeout' do
  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
        when => refreshed,
        timeout => 120,
      }
    MANIFEST
  end

  it 'Reboot Immediately with a Custom Timeout' do
    apply_manifest(reboot_manifest, debug: true) do |result|
      if os[:family] == 'windows'
        expect(result.stdout).to match(%r{shutdown\.exe \/r \/t 120 \/d p:4:1})
      else
        expect(result.stdout).to match(%r{shutdown -r \+2})
      end
      expect(reboot_issued_or_cancelled(['-r', '+2', 'Puppet', 'is', 'rebooting', 'the', 'computer'])).to be (true)
    end
  end
end
