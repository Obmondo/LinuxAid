require 'spec_helper_acceptance'

describe 'Reboot Immediately and Explicit Immediately' do
  let(:reboot_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
      }
    MANIFEST
  end

  let(:reboot_immediate_manifest) do
    <<-MANIFEST
      notify { 'step_1':
      }
      ~>
      reboot { 'now':
        apply => immediately
      }
    MANIFEST
  end

  let(:skip_msg_pattern) { %r{Transaction canceled, skipping} }

  it 'Reboot Immediately with Refresh' do
    result = apply_manifest(reboot_manifest, debug: true, catch_failures: true)
    expect(result.stdout).to match(skip_msg_pattern)
    expect(reboot_issued_or_cancelled).to eq(true)
  end

  it 'Reboot Immediately explicit with Refresh' do
    result = apply_manifest(reboot_immediate_manifest, debug: true, catch_failures: true)
    expect(result.stdout).to match(skip_msg_pattern)
    expect(reboot_issued_or_cancelled).to eq(true)
  end
end
