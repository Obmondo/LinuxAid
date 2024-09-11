require 'spec_helper'

describe Puppet::Type.type(:cron).provider(:crontab) do
  let :provider do
    described_class.new(command: '/bin/true')
  end

  let :resource do
    Puppet::Type.type(:cron).new(
      minute: ['0', '15', '30', '45'],
      hour: ['8-18', '20-22'],
      monthday: ['31'],
      month: ['12'],
      weekday: ['7'],
      name: 'basic',
      command: '/bin/true',
      target: 'root',
      provider: provider,
    )
  end

  let :resource_special do
    Puppet::Type.type(:cron).new(
      special: 'reboot',
      name: 'special',
      command: '/bin/true',
      target: 'nobody',
    )
  end

  let :resource_sparse do
    Puppet::Type.type(:cron).new(
      minute: ['42'],
      target: 'root',
      name: 'sparse',
    )
  end

  let :record_special do
    {
      record_type: :crontab,
      special: 'reboot',
      command: '/bin/true',
      on_disk: true,
      target: 'nobody',
    }
  end

  let :record do
    {
      record_type: :crontab,
      minute: ['0', '15', '30', '45'],
      hour: ['8-18', '20-22'],
      monthday: ['31'],
      month: ['12'],
      weekday: ['7'],
      special: :absent,
      command: '/bin/true',
      on_disk: true,
      target: 'root',
    }
  end

  describe 'when determining the correct filetype' do
    it 'uses the suntab filetype on Solaris' do
      Facter.stubs(:value).with(:osfamily).returns 'Solaris'
      expect(described_class.filetype).to eq(Puppet::Provider::Cron::FileType::FileTypeSuntab)
    end

    it 'uses the aixtab filetype on AIX' do
      Facter.stubs(:value).with(:osfamily).returns 'AIX'
      expect(described_class.filetype).to eq(Puppet::Provider::Cron::FileType::FileTypeAixtab)
    end

    it 'uses the crontab filetype on other platforms' do
      Facter.stubs(:value).with(:osfamily).returns 'Not a real operating system family'
      expect(described_class.filetype).to eq(Puppet::Provider::Cron::FileType::FileTypeCrontab)
    end
  end

  # I'd use ENV.expects(:[]).with('USER') but this does not work because
  # ENV["USER"] is evaluated at load time.
  describe 'when determining the default target' do
    it "should use the current user #{ENV['USER']}", if: ENV['USER'] do
      expect(described_class.default_target).to eq(ENV['USER'])
    end

    it 'fallbacks to root', unless: ENV['USER'] do
      expect(described_class.default_target).to eq('root')
    end
  end

  describe '.targets' do
    let(:tabs) { [described_class.default_target] + ['foo', 'bar'] }

    before(:each) do
      File.expects(:readable?).returns true
      File.stubs(:file?).returns true
      File.stubs(:writable?).returns true
    end
    after(:each) do
      File.unstub :readable?, :file?, :writable?
      Dir.unstub :foreach
    end
    it 'adds all crontabs as targets' do
      Dir.expects(:foreach).multiple_yields(*tabs)
      expect(described_class.targets).to eq(tabs)
    end
  end

  describe 'when parsing a record' do
    it 'parses a comment' do
      expect(described_class.parse_line('# This is a test')).to eq(record_type: :comment,
                                                                   line: '# This is a test')
    end

    it 'gets the resource name of a PUPPET NAME comment' do
      expect(described_class.parse_line('# Puppet Name: My Fancy Cronjob')).to eq(record_type: :comment,
                                                                                  name: 'My Fancy Cronjob',
                                                                                  line: '# Puppet Name: My Fancy Cronjob')
    end

    it 'ignores blank lines' do
      expect(described_class.parse_line('')).to eq(record_type: :blank, line: '')
      expect(described_class.parse_line(' ')).to eq(record_type: :blank, line: ' ')
      expect(described_class.parse_line("\t")).to eq(record_type: :blank, line: "\t")
      expect(described_class.parse_line("  \t ")).to eq(record_type: :blank, line: "  \t ")
    end

    it 'extracts environment assignments' do
      # man 5 crontab: MAILTO="" with no value can be used to surpress sending
      # mails at all
      expect(described_class.parse_line('MAILTO=""')).to eq(record_type: :environment, line: 'MAILTO=""')
      expect(described_class.parse_line('FOO=BAR')).to eq(record_type: :environment, line: 'FOO=BAR')
      expect(described_class.parse_line('FOO_BAR=BAR')).to eq(record_type: :environment, line: 'FOO_BAR=BAR')
      expect(described_class.parse_line('SPACE = BAR')).to eq(record_type: :environment, line: 'SPACE = BAR')
    end

    it 'extracts a cron entry' do
      expect(described_class.parse_line('* * * * * /bin/true')).to eq(record_type: :crontab,
                                                                      hour: :absent,
                                                                      minute: :absent,
                                                                      month: :absent,
                                                                      weekday: :absent,
                                                                      monthday: :absent,
                                                                      special: :absent,
                                                                      command: '/bin/true')
      expect(described_class.parse_line('0,15,30,45 8-18,20-22 31 12 7 /bin/true')).to eq(record_type: :crontab,
                                                                                          minute: ['0', '15', '30', '45'],
                                                                                          hour: ['8-18', '20-22'],
                                                                                          monthday: ['31'],
                                                                                          month: ['12'],
                                                                                          weekday: ['7'],
                                                                                          special: :absent,
                                                                                          command: '/bin/true')
      # A percent sign will cause the rest of the string to be passed as
      # standard input and will also act as a newline character. Not sure
      # if puppet should convert % to a \n as the command property so the
      # test covers the current behaviour: Do not do any conversions
      expect(described_class.parse_line('0 22 * * 1-5   mail -s "It\'s 10pm" joe%Joe,%%Where are your kids?%')).to eq(record_type: :crontab,
                                                                                                                      minute: ['0'],
                                                                                                                      hour: ['22'],
                                                                                                                      monthday: :absent,
                                                                                                                      month: :absent,
                                                                                                                      weekday: ['1-5'],
                                                                                                                      special: :absent,
                                                                                                                      command: 'mail -s "It\'s 10pm" joe%Joe,%%Where are your kids?%')
    end

    describe 'it should support special strings' do
      ['reboot', 'yearly', 'anually', 'monthly', 'weekly', 'daily', 'midnight', 'hourly'].each do |special|
        it "should support @#{special}" do
          expect(described_class.parse_line("@#{special} /bin/true")).to eq(record_type: :crontab,
                                                                            hour: :absent,
                                                                            minute: :absent,
                                                                            month: :absent,
                                                                            weekday: :absent,
                                                                            monthday: :absent,
                                                                            special: special,
                                                                            command: '/bin/true')
        end
      end
    end
  end

  describe '.instances' do
    before :each do
      described_class.stubs(:default_target).returns 'foobar'
    end

    describe 'on linux' do
      before(:each) do
        Facter.stubs(:value).with(:osfamily).returns 'Linux'
        Facter.stubs(:value).with(:operatingsystem)
      end

      it 'contains no resources for a user who has no crontab' do
        Puppet::Util.stubs(:uid).returns(10)

        Puppet::Util::Execution
          .expects(:execute)
          .with('crontab -u foobar -l', failonfail: true, combine: true)
          .returns('')

        expect(described_class.instances.select do |resource|
          resource.get('target') == 'foobar'
        end).to be_empty
      end

      it 'contains no resources for a user who is absent' do
        Puppet::Util.stubs(:uid).returns(nil)

        expect(described_class.instances).to be_empty
      end

      it 'is able to create records from not-managed records' do
        described_class.stubs(:target_object).returns File.new(my_fixture('simple'))
        parameters = described_class.instances.map do |p|
          h = { name: p.get(:name) }
          Puppet::Type.type(:cron).validproperties.each do |property|
            h[property] = p.get(property)
          end
          h
        end

        expect(parameters[0][:name]).to match(%r{unmanaged:\$HOME/bin/daily.job_>>_\$HOME/tmp/out_2>&1-\d+})
        expect(parameters[0][:minute]).to eq(['5'])
        expect(parameters[0][:hour]).to eq(['0'])
        expect(parameters[0][:weekday]).to eq(:absent)
        expect(parameters[0][:month]).to eq(:absent)
        expect(parameters[0][:monthday]).to eq(:absent)
        expect(parameters[0][:special]).to eq(:absent)
        expect(parameters[0][:command]).to match(%r{\$HOME/bin/daily.job >> \$HOME/tmp/out 2>&1})
        expect(parameters[0][:ensure]).to eq(:present)
        expect(parameters[0][:environment]).to eq(:absent)
        expect(parameters[0][:user]).to eq(:absent)

        expect(parameters[1][:name]).to match(%r{unmanaged:\$HOME/bin/monthly-\d+})
        expect(parameters[1][:minute]).to eq(['15'])
        expect(parameters[1][:hour]).to eq(['14'])
        expect(parameters[1][:weekday]).to eq(:absent)
        expect(parameters[1][:month]).to eq(:absent)
        expect(parameters[1][:monthday]).to eq(['1'])
        expect(parameters[1][:special]).to eq(:absent)
        expect(parameters[1][:command]).to match(%r{\$HOME/bin/monthly})
        expect(parameters[1][:ensure]).to eq(:present)
        expect(parameters[1][:environment]).to eq(:absent)
        expect(parameters[1][:user]).to eq(:absent)
        expect(parameters[1][:target]).to eq('foobar')
      end

      it 'is able to parse puppet managed cronjobs' do
        described_class.stubs(:target_object).returns File.new(my_fixture('managed'))
        expect(described_class.instances.map do |p|
          h = { name: p.get(:name) }
          Puppet::Type.type(:cron).validproperties.each do |property|
            h[property] = p.get(property)
          end
          h
        end).to eq([
                     {
                       name: 'real_job',
                       minute: :absent,
                       hour: :absent,
                       weekday: :absent,
                       month: :absent,
                       monthday: :absent,
                       special: :absent,
                       command: '/bin/true',
                       ensure: :present,
                       environment: :absent,
                       user: :absent,
                       target: 'foobar',
                     },
                     {
                       name: 'complex_job',
                       minute: :absent,
                       hour: :absent,
                       weekday: :absent,
                       month: :absent,
                       monthday: :absent,
                       special: 'reboot',
                       command: '/bin/true >> /dev/null 2>&1',
                       ensure: :present,
                       environment: [
                         'MAILTO=foo@example.com',
                         'SHELL=/bin/sh',
                       ],
                       user: :absent,
                       target: 'foobar',
                     },
                   ])
      end
    end
  end

  describe '.match' do
    describe 'normal records' do
      it 'matches when all fields are the same' do
        expect(described_class.match(record, resource[:name] => resource)).to eq(resource)
      end

      {
        minute: ['0', '15', '31', '45'],
        hour: ['8-18'],
        monthday: ['30', '31'],
        month: ['12', '23'],
        weekday: ['4'],
        command: '/bin/false',
        target: 'nobody',
      }.each_pair do |field, new_value|
        it "should not match a record when #{field} does not match" do
          record[field] = new_value
          expect(described_class.match(record, resource[:name] => resource)).to be_falsey
        end
      end
    end

    describe 'special records' do
      it 'matches when all fields are the same' do
        expect(described_class.match(record_special, resource_special[:name] => resource_special)).to eq(resource_special)
      end

      {
        special: 'monthly',
        command: '/bin/false',
        target: 'root',
      }.each_pair do |field, new_value|
        it "should not match a record when #{field} does not match" do
          record_special[field] = new_value
          expect(described_class.match(record_special, resource_special[:name] => resource_special)).to be_falsey
        end
      end
    end

    describe 'with a resource without a command' do
      it 'does not raise an error' do
        expect { described_class.match(record, resource_sparse[:name] => resource_sparse) }.not_to raise_error
      end
    end
  end
end
