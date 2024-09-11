require 'spec_helper_acceptance'

describe 'No Refresh' do
  let(:reboot_manifest) do
    <<-MANIFEST
      reboot { 'now':
      }
    MANIFEST
  end

  it 'does not Reboot Computer without Refresh' do
    apply_manifest(reboot_manifest, catch_failures: true)
    expect(reboot_issued_or_cancelled).to be(true)
  end
end
