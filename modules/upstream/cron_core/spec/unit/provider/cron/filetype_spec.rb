require 'spec_helper'
require 'puppet/provider/cron/filetype'

# rubocop:disable RSpec/FilePath
describe Puppet::Provider::Cron::FileType do
  shared_examples_for 'crontab provider' do
    let(:cron)         { type.new('no_such_user') }
    let(:crontab)      { File.read(my_fixture(crontab_output)) }
    let(:options)      { { failonfail: true, combine: true } }
    let(:uid)          { 'no_such_user' }
    let(:user_options) { options.merge(uid: uid) }

    it 'exists' do
      expect(type).not_to be_nil
    end

    # make Puppet::Util::SUIDManager return something deterministic, not the
    # uid of the user running the tests, except where overridden below.
    before :each do
      Puppet::Util::SUIDManager.stubs(:uid).returns 1234
    end

    describe '#read' do
      before(:each) do
        Puppet::Util.stubs(:uid).with(uid).returns 9000
      end

      it 'runs crontab -l as the target user' do
        Puppet::Util::Execution
          .expects(:execute)
          .with(['crontab', '-l'], user_options)
          .returns(Puppet::Util::Execution::ProcessOutput.new(crontab, 0))

        expect(cron.read).to eq(crontab)
      end

      it 'does not switch user if current user is the target user' do
        Puppet::Util.expects(:uid).with(uid).twice.returns 9000
        Puppet::Util::SUIDManager.expects(:uid).returns 9000
        Puppet::Util::Execution
          .expects(:execute).with(['crontab', '-l'], options)
          .returns(Puppet::Util::Execution::ProcessOutput.new(crontab, 0))
        expect(cron.read).to eq(crontab)
      end

      it 'treats an absent crontab as empty' do
        Puppet::Util::Execution.expects(:execute).with(['crontab', '-l'], user_options).raises(Puppet::ExecutionFailure, absent_crontab)
        expect(cron.read).to eq('')
      end

      it "treats a nonexistent user's crontab as empty" do
        Puppet::Util.expects(:uid).with(uid).returns nil

        expect(cron.read).to eq('')
      end

      it 'returns empty if the user is not authorized to use cron' do
        Puppet::Util::Execution.expects(:execute).with(['crontab', '-l'], user_options).raises(Puppet::ExecutionFailure, unauthorized_crontab)
        expect(cron.read).to eq('')
      end
    end

    describe '#remove' do
      it 'runs crontab -r as the target user' do
        Puppet::Util::Execution.expects(:execute).with(['crontab', '-r'], user_options)
        cron.remove
      end

      it 'does not switch user if current user is the target user' do
        Puppet::Util.expects(:uid).with(uid).returns 9000
        Puppet::Util::SUIDManager.expects(:uid).returns 9000
        Puppet::Util::Execution.expects(:execute).with(['crontab', '-r'], options)
        cron.remove
      end
    end

    describe '#write' do
      let!(:tmp_cron) { Tempfile.new('puppet_crontab_spec') }
      let!(:tmp_cron_path) { tmp_cron.path }

      before :each do
        Puppet::Util.stubs(:uid).with(uid).returns 9000
        Tempfile.expects(:new).with("puppet_#{name}", encoding: Encoding.default_external).returns tmp_cron
      end

      after :each do
        File.unstub(:chown)
      end

      it 'runs crontab as the target user on a temporary file' do
        File.expects(:chown).with(9000, nil, tmp_cron_path)
        Puppet::Util::Execution.expects(:execute).with(['crontab', tmp_cron_path], user_options)

        tmp_cron.expects(:print).with("foo\n")
        cron.write "foo\n"

        expect(Puppet::FileSystem).not_to exist(tmp_cron_path)
      end

      it 'does not switch user if current user is the target user' do
        Puppet::Util::SUIDManager.expects(:uid).returns 9000
        File.expects(:chown).with(9000, nil, tmp_cron_path)
        Puppet::Util::Execution.expects(:execute).with(['crontab', tmp_cron_path], options)

        tmp_cron.expects(:print).with("foo\n")
        cron.write "foo\n"

        expect(Puppet::FileSystem).not_to exist(tmp_cron_path)
      end
    end
  end

  describe 'the suntab filetype', unless: Puppet::Util::Platform.windows? do
    let(:type)           { described_class.filetype(:suntab) }
    let(:name)           { type.name }
    let(:crontab_output) { 'suntab_output' }

    # possible crontab output was taken from here:
    # https://docs.oracle.com/cd/E19082-01/819-2380/sysrescron-60/index.html
    let(:absent_crontab) do
      'crontab: can\'t open your crontab file'
    end
    let(:unauthorized_crontab) do
      'crontab: you are not authorized to use cron. Sorry.'
    end

    it_behaves_like 'crontab provider'
  end

  describe 'the aixtab filetype', unless: Puppet::Util::Platform.windows? do
    let(:type)           { described_class.filetype(:aixtab) }
    let(:name)           { type.name }
    let(:crontab_output) { 'aixtab_output' }

    let(:absent_crontab) do
      '0481-103 Cannot open a file in the /var/spool/cron/crontabs directory.'
    end
    let(:unauthorized_crontab) do
      '0481-109 You are not authorized to use the cron command.'
    end

    it_behaves_like 'crontab provider'
  end
end
