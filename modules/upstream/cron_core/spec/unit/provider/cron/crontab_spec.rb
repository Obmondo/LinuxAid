require 'spec_helper'

describe Puppet::Type.type(:cron).provider(:crontab) do
  subject do
    provider = Puppet::Type.type(:cron).provider(:crontab)
    provider.initvars
    provider
  end

  def compare_crontab_text(have, want)
    # We should have four header lines, and then the text...
    expect(have.lines.to_a[0..3]).to(be_all { |x| x =~ %r{^# } })
    expect(have.lines.to_a[4..-1].join('')).to eq(want)
  end

  context 'with the simple samples' do
    FIELDS = {
      crontab: ['command', 'minute', 'hour', 'month', 'monthday', 'weekday'].map { |o| o.to_sym },
      environment: [:line],
      blank: [:line],
      comment: [:line],
    }.freeze

    def compare_crontab_record(have, want)
      want.each do |param, value|
        expect(have).to be_key param
        expect(have[param]).to eq(value)
      end

      (FIELDS[have[:record_type]] - want.keys).each do |name|
        expect(have[name]).to eq(:absent)
      end
    end

    ########################################################################
    # Simple input fixtures for testing.
    samples = YAML.load(File.read(my_fixture('single_line.yaml'))) # rubocop:disable Security/YAMLLoad

    samples.each do |name, data|
      it "should parse crontab line #{name} correctly" do
        compare_crontab_record subject.parse_line(data[:text]), data[:record]
      end

      it "should reconstruct the crontab line #{name} from the record" do
        expect(subject.to_line(data[:record])).to eq(data[:text])
      end
    end

    records = []
    text    = ''

    # Sorting is from the original, and avoids :empty being the last line,
    # since the provider will ignore that and cause this to fail.
    samples.sort_by { |x| x.first.to_s }.each do |_name, data|
      records << data[:record]
      text    << data[:text] + "\n"
    end

    it 'parses all sample records at once' do
      subject.parse(text).zip(records).each do |round|
        compare_crontab_record(*round)
      end
    end

    it 'reconstitutes the file from the records' do
      compare_crontab_text subject.to_file(records), text
    end

    context 'multi-line crontabs' do
      tests = { simple: [:spaces_in_command_with_times],
                with_name: [:name, :spaces_in_command_with_times],
                with_env: [:environment, :spaces_in_command_with_times],
                with_multiple_envs: [:environment, :lowercase_environment, :spaces_in_command_with_times],
                with_name_and_env: [:name_with_spaces, :another_env, :spaces_in_command_with_times],
                with_name_and_multiple_envs: [:long_name, :another_env, :fourth_env, :spaces_in_command_with_times] }

      all_records = []
      all_text    = ''

      tests.each do |name, content|
        data    = content.map { |x| samples[x] || raise("missing sample data #{x}") }
        text    = data.map { |x| x[:text] }.join("\n") + "\n"
        records = data.map { |x| x[:record] }

        # Capture the whole thing for later, too...
        all_records += records
        all_text    += text

        context name.to_s.tr('_', ' ') do
          it 'regenerates the text from the record' do
            compare_crontab_text subject.to_file(records), text
          end

          it 'parses the records from the text' do
            subject.parse(text).zip(records).each do |round|
              compare_crontab_record(*round)
            end
          end
        end
      end

      it 'parses the whole set of records from the text' do
        subject.parse(all_text).zip(all_records).each do |round|
          compare_crontab_record(*round)
        end
      end

      it 'regenerates the whole text from the set of all records' do
        compare_crontab_text subject.to_file(all_records), all_text
      end
    end
  end

  context 'when receiving a vixie cron header from the cron interface' do
    it 'does not write that header back to disk' do
      vixie_header = File.read(my_fixture('vixie_header.txt'))
      vixie_records = subject.parse(vixie_header)
      compare_crontab_text subject.to_file(vixie_records), ''
    end
  end

  context 'when adding a cronjob with the same command as an existing job' do
    let(:record) { { name: 'existing', user: 'root', command: '/bin/true', record_type: :crontab } }
    let(:resource) { Puppet::Type::Cron.new(name: 'test', user: 'root', command: '/bin/true') }
    let(:resources) { { 'test' => resource } }

    before :each do
      subject.stubs(:prefetch_all_targets).returns([record])
    end

    # this would be a more fitting test, but I haven't yet
    # figured out how to get it working
    #    it "should include both jobs in the output" do
    #      subject.prefetch(resources)
    #      class Puppet::Provider::ParsedFile
    #        def self.records
    #          @records
    #        end
    #      end
    #      subject.to_file(subject.records).should match /Puppet name: test/
    #    end

    it "does not base the new resource's provider on the existing record" do
      subject.expects(:new).with(record).never
      subject.stubs(:new)
      subject.prefetch(resources)
    end
  end

  context 'when prefetching an entry now managed for another user' do
    let(:resource) do
      s = stub(:resource)
      s.stubs(:[]).with(:user).returns 'root'
      s.stubs(:[]).with(:target).returns 'root'
      s
    end

    let(:record) { { name: 'test', user: 'nobody', command: '/bin/true', record_type: :crontab } }
    let(:resources) { { 'test' => resource } }

    before :each do
      subject.stubs(:prefetch_all_targets).returns([record])
    end

    it 'tries and use the match method to find a more fitting record' do
      subject.expects(:match).with(record, resources)
      subject.prefetch(resources)
    end

    it 'does not match a provider to the resource' do
      resource.expects(:provider=).never
      subject.prefetch(resources)
    end

    it 'does not find the resource when looking up the on-disk record' do
      subject.prefetch(resources)
      expect(subject.resource_for_record(record, resources)).to be_nil
    end
  end

  context 'when matching resources to existing crontab entries' do
    let(:first_resource) { Puppet::Type::Cron.new(name: :one, user: 'root', command: '/bin/true') }
    let(:second_resource) { Puppet::Type::Cron.new(name: :two, user: 'nobody', command: '/bin/false') }

    let(:resources) { { one: first_resource, two: second_resource } }

    describe 'with a record with a matching name and mismatching user (#2251)' do
      # Puppet::Resource objects have #should defined on them, so in these
      # examples we have to use the monkey patched `must` alias for the rspec
      # `should` method.

      it "doesn't match the record to the resource" do
        record = { name: :one, user: 'notroot', record_type: :crontab }
        expect(subject.resource_for_record(record, resources)).to be_nil
      end
    end

    describe 'with a record with a matching name and matching user' do
      it 'matches the record to the resource' do
        record = { name: :two, target: 'nobody', command: '/bin/false' }
        expect(subject.resource_for_record(record, resources)).to eq(second_resource)
      end
    end
  end

  context '#enumerate_crontabs' do
    before(:each) do
      File.expects(:readable?).with(subject.crontab_dir).returns(true)
      Dir.expects(:foreach).with(subject.crontab_dir).multiple_yields(*files)
    end

    context 'only a hidden file' do
      let(:files) { ['.keep_cronbase-0'] }

      before(:each) do
        files.each do |filename|
          path = File.join(subject.crontab_dir, filename)
          File.expects(:file?).with(path).returns(true)
          File.expects(:writable?).with(path).returns(true)
        end
      end

      it 'ignores .keep_* files' do
        expect { |b| described_class.enumerate_crontabs(&b) }.not_to yield_control
      end
    end

    context 'multiple files' do
      let(:files) { ['myuser', '.keep_cronbase-0'] }

      before(:each) do
        files.each do |filename|
          path = File.join(subject.crontab_dir, filename)
          File.expects(:file?).with(path).returns(true)
          File.expects(:writable?).with(path).returns(true)
        end
      end

      it 'ignores .keep_* files' do
        expect { |b| described_class.enumerate_crontabs(&b) }.to yield_control.once
      end
    end
  end
end
