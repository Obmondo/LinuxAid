require 'spec_helper_acceptance'

describe 'Puppet Resume after Reboot' do
  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'first message':
      } ~>
      reboot { 'first_reboot':
      } ->
      notify { 'second message':
      } ~>
      reboot { 'second_reboot':
      }
    MANIFEST
  end

  it 'Attempt First Reboot' do
    result = apply_manifest(reboot_manifest, debug: true, catch_failures: true)
    expect(result.stdout).to match(%r{first\smessage})
    expect(reboot_issued_or_cancelled).to be(true)
  end

  it 'Resume After Reboot' do
    result = apply_manifest(reboot_manifest, debug: true, catch_failures: true)
    expect(result.stdout).to match(%r{second\smessage})
    expect(reboot_issued_or_cancelled).to be(true)
  end

  it 'Verify Manifest is Finished' do
    apply_manifest(reboot_manifest)
    expect(reboot_issued_or_cancelled).to be(true)
  end
end
