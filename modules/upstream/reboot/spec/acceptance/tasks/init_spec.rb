require 'spec_helper_acceptance'

describe 'reboot task', bolt: true do

  let(:tm) { 60 }
  let(:bolt_default_reboot_args) {['-r', '+1', "''", '</dev/null', '>/dev/null', '2>&1', '&']}
  let(:bolt_reboot_args_with_msg) {['-r', '+1', 'Bolt\\', 'is\\', 'rebooting\\', 'the\\', 'computer', '</dev/null', '>/dev/null', '2>&1', '&']}

  it 'reports the last boot time' do
    result = run_bolt_task('reboot::last_boot_time')
    expect(bolt_result_as_hash(result)['_output']).not_to be_empty
    expect(result.stderr).to be(nil)
    expect(result.exit_code).to be(0)
  end

  it 'reboots a target' do
    result = run_bolt_task('reboot', 'timeout' => tm)
    expect(bolt_result_as_hash(result)['status']).to eq('queued')
    expect(bolt_result_as_hash(result)['timeout']).to eq(tm)
    expect(reboot_issued_or_cancelled(bolt_default_reboot_args)).to be(true)
  end

  it 'accepts a message' do
    result = run_bolt_task('reboot', 'timeout' => tm, 'message' => 'Bolt is rebooting the computer')
    expect(bolt_result_as_hash(result)['status']).to eq('queued')
    expect(bolt_result_as_hash(result)['timeout']).to eq(tm)
    expect(reboot_issued_or_cancelled(bolt_reboot_args_with_msg)).to be(true)
  end
end
