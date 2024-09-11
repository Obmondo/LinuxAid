require 'spec_helper'

describe Puppet::Type.type(:cron), unless: Puppet.features.microsoft_windows? do
  let(:simple_provider) do
    provider_class = described_class.provide(:simple) { mk_resource_methods }
    provider_class.stubs(:suitable?).returns true
    provider_class
  end

  before :each do
    described_class.stubs(:defaultprovider).returns simple_provider
  end

  after :each do
    described_class.unprovide(:simple)
  end

  it 'has :name be its namevar' do
    expect(described_class.key_attributes).to eq([:name])
  end

  describe 'when validating attributes' do
    [:name, :provider].each do |param|
      it "should have a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:command, :special, :minute, :hour, :weekday, :month, :monthday, :environment, :user, :target].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end

    [:command, :minute, :hour, :weekday, :month, :monthday].each do |cronparam|
      it "should have #{cronparam} of type CronParam" do
        expect(described_class.attrclass(cronparam).ancestors).to include CronParam
      end
    end
  end

  describe 'when validating values' do
    describe 'ensure' do
      it 'supports present as a value for ensure' do
        expect { described_class.new(name: 'foo', ensure: :present) }.not_to raise_error
      end

      it 'supports absent as a value for ensure' do
        expect { described_class.new(name: 'foo', ensure: :absent) }.not_to raise_error
      end

      it 'does not support other values' do
        expect { described_class.new(name: 'foo', ensure: :foo) }.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    describe 'command' do
      it 'discards leading spaces' do
        expect(described_class.new(name: 'foo', command: ' /bin/true')[:command]).not_to match Regexp.new(' ')
      end
      it 'discards trailing spaces' do
        expect(described_class.new(name: 'foo', command: '/bin/true ')[:command]).not_to match Regexp.new(' ')
      end
    end

    describe 'minute' do
      it 'supports absent' do
        expect { described_class.new(name: 'foo', minute: 'absent') }.not_to raise_error
      end

      it 'supports *' do
        expect { described_class.new(name: 'foo', minute: '*') }.not_to raise_error
      end

      it 'translates absent to :absent' do
        expect(described_class.new(name: 'foo', minute: 'absent')[:minute]).to eq(:absent)
      end

      it 'translates * to :absent' do
        expect(described_class.new(name: 'foo', minute: '*')[:minute]).to eq(:absent)
      end

      it 'supports valid single values' do
        expect { described_class.new(name: 'foo', minute: '0') }.not_to raise_error
        expect { described_class.new(name: 'foo', minute: '1') }.not_to raise_error
        expect { described_class.new(name: 'foo', minute: '59') }.not_to raise_error
      end

      it 'does not support non numeric characters' do
        expect { described_class.new(name: 'foo', minute: 'z59') }.to raise_error(Puppet::Error, %r{z59 is not a valid minute})
        expect { described_class.new(name: 'foo', minute: '5z9') }.to raise_error(Puppet::Error, %r{5z9 is not a valid minute})
        expect { described_class.new(name: 'foo', minute: '59z') }.to raise_error(Puppet::Error, %r{59z is not a valid minute})
      end

      it 'does not support single values out of range' do
        expect { described_class.new(name: 'foo', minute: '-1') }.to raise_error(Puppet::Error, %r{-1 is not a valid minute})
        expect { described_class.new(name: 'foo', minute: '60') }.to raise_error(Puppet::Error, %r{60 is not a valid minute})
        expect { described_class.new(name: 'foo', minute: '61') }.to raise_error(Puppet::Error, %r{61 is not a valid minute})
        expect { described_class.new(name: 'foo', minute: '120') }.to raise_error(Puppet::Error, %r{120 is not a valid minute})
      end

      it 'supports valid multiple values' do
        expect { described_class.new(name: 'foo', minute: ['0', '1', '59']) }.not_to raise_error
        expect { described_class.new(name: 'foo', minute: ['40', '30', '20']) }.not_to raise_error
        expect { described_class.new(name: 'foo', minute: ['10', '30', '20']) }.not_to raise_error
      end

      it 'does not support multiple values if at least one is invalid' do
        # one invalid
        expect { described_class.new(name: 'foo', minute: ['0', '1', '60']) }.to raise_error(Puppet::Error, %r{60 is not a valid minute})
        expect { described_class.new(name: 'foo', minute: ['0', '120', '59']) }.to raise_error(Puppet::Error, %r{120 is not a valid minute})
        expect { described_class.new(name: 'foo', minute: ['-1', '1', '59']) }.to raise_error(Puppet::Error, %r{-1 is not a valid minute})
        # two invalid
        expect { described_class.new(name: 'foo', minute: ['0', '61', '62']) }.to raise_error(Puppet::Error, %r{(61|62) is not a valid minute})
        # all invalid
        expect { described_class.new(name: 'foo', minute: ['-1', '61', '62']) }.to raise_error(Puppet::Error, %r{(-1|61|62) is not a valid minute})
      end

      it 'supports valid step syntax' do
        expect { described_class.new(name: 'foo', minute: '*/2') }.not_to raise_error
        expect { described_class.new(name: 'foo', minute: '10-16/2') }.not_to raise_error
      end

      it 'does not support invalid steps' do
        expect { described_class.new(name: 'foo', minute: '*/A') }.to raise_error(Puppet::Error, %r{\*/A is not a valid minute})
        expect { described_class.new(name: 'foo', minute: '*/2A') }.to raise_error(Puppet::Error, %r{\*/2A is not a valid minute})
        # As it turns out cron does not complaining about steps that exceed the valid range
        # expect { described_class.new(:name => 'foo', :minute => '*/120' ) }.to raise_error(Puppet::Error, /is not a valid minute/)
      end

      it 'supports values with leading zeros' do
        expect { described_class.new(name: 'foo', minute: ['0', '0011', '044']) }.not_to raise_error
        expect { described_class.new(name: 'foo', minute: '022') }.not_to raise_error
      end

      it 'does not remove leading zeroes' do
        expect(described_class.new(name: 'foo', minute: '0045')[:minute]).to eq(['0045'])
      end
    end

    describe 'hour' do
      it 'supports absent' do
        expect { described_class.new(name: 'foo', hour: 'absent') }.not_to raise_error
      end

      it 'supports *' do
        expect { described_class.new(name: 'foo', hour: '*') }.not_to raise_error
      end

      it 'translates absent to :absent' do
        expect(described_class.new(name: 'foo', hour: 'absent')[:hour]).to eq(:absent)
      end

      it 'translates * to :absent' do
        expect(described_class.new(name: 'foo', hour: '*')[:hour]).to eq(:absent)
      end

      it 'supports valid single values' do
        expect { described_class.new(name: 'foo', hour: '0') }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: '11') }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: '12') }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: '13') }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: '23') }.not_to raise_error
      end

      it 'does not support non numeric characters' do
        expect { described_class.new(name: 'foo', hour: 'z15') }.to raise_error(Puppet::Error, %r{z15 is not a valid hour})
        expect { described_class.new(name: 'foo', hour: '1z5') }.to raise_error(Puppet::Error, %r{1z5 is not a valid hour})
        expect { described_class.new(name: 'foo', hour: '15z') }.to raise_error(Puppet::Error, %r{15z is not a valid hour})
      end

      it 'does not support single values out of range' do
        expect { described_class.new(name: 'foo', hour: '-1') }.to raise_error(Puppet::Error, %r{-1 is not a valid hour})
        expect { described_class.new(name: 'foo', hour: '24') }.to raise_error(Puppet::Error, %r{24 is not a valid hour})
        expect { described_class.new(name: 'foo', hour: '120') }.to raise_error(Puppet::Error, %r{120 is not a valid hour})
      end

      it 'supports valid multiple values' do
        expect { described_class.new(name: 'foo', hour: ['0', '1', '23']) }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: ['5', '16', '14']) }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: ['16', '13', '9']) }.not_to raise_error
      end

      it 'does not support multiple values if at least one is invalid' do
        # one invalid
        expect { described_class.new(name: 'foo', hour: ['0', '1', '24']) }.to raise_error(Puppet::Error, %r{24 is not a valid hour})
        expect { described_class.new(name: 'foo', hour: ['0', '-1', '5']) }.to raise_error(Puppet::Error, %r{-1 is not a valid hour})
        expect { described_class.new(name: 'foo', hour: ['-1', '1', '23']) }.to raise_error(Puppet::Error, %r{-1 is not a valid hour})
        # two invalid
        expect { described_class.new(name: 'foo', hour: ['0', '25', '26']) }.to raise_error(Puppet::Error, %r{(25|26) is not a valid hour})
        # all invalid
        expect { described_class.new(name: 'foo', hour: ['-1', '24', '120']) }.to raise_error(Puppet::Error, %r{(-1|24|120) is not a valid hour})
      end

      it 'supports valid step syntax' do
        expect { described_class.new(name: 'foo', hour: '*/2') }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: '10-18/4') }.not_to raise_error
      end

      it 'does not support invalid steps' do
        expect { described_class.new(name: 'foo', hour: '*/A') }.to raise_error(Puppet::Error, %r{\*/A is not a valid hour})
        expect { described_class.new(name: 'foo', hour: '*/2A') }.to raise_error(Puppet::Error, %r{\*/2A is not a valid hour})
        # As it turns out cron does not complaining about steps that exceed the valid range
        # expect { described_class.new(:name => 'foo', :hour => '*/26' ) }.to raise_error(Puppet::Error, /is not a valid hour/)
      end

      it 'supports values with leading zeros' do
        expect { described_class.new(name: 'foo', hour: ['007', '1', '0023']) }.not_to raise_error
        expect { described_class.new(name: 'foo', hour: '022') }.not_to raise_error
      end

      it 'does not remove leading zeroes' do
        expect(described_class.new(name: 'foo', hour: '005')[:hour]).to eq(['005'])
      end
    end

    describe 'weekday' do
      it 'supports absent' do
        expect { described_class.new(name: 'foo', weekday: 'absent') }.not_to raise_error
      end

      it 'supports *' do
        expect { described_class.new(name: 'foo', weekday: '*') }.not_to raise_error
      end

      it 'translates absent to :absent' do
        expect(described_class.new(name: 'foo', weekday: 'absent')[:weekday]).to eq(:absent)
      end

      it 'translates * to :absent' do
        expect(described_class.new(name: 'foo', weekday: '*')[:weekday]).to eq(:absent)
      end

      it 'supports valid numeric weekdays' do
        expect { described_class.new(name: 'foo', weekday: '0') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: '1') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: '6') }.not_to raise_error
        # According to http://www.manpagez.com/man/5/crontab 7 is also valid (Sunday)
        expect { described_class.new(name: 'foo', weekday: '7') }.not_to raise_error
      end

      it 'supports valid weekdays as words (long version)' do
        expect { described_class.new(name: 'foo', weekday: 'Monday') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Tuesday') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Wednesday') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Thursday') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Friday') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Saturday') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Sunday') }.not_to raise_error
      end

      it 'supports valid weekdays as words (3 character version)' do
        expect { described_class.new(name: 'foo', weekday: 'Mon') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Tue') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Wed') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Thu') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Fri') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Sat') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: 'Sun') }.not_to raise_error
      end

      it 'does not support numeric values out of range' do
        expect { described_class.new(name: 'foo', weekday: '-1') }.to raise_error(Puppet::Error, %r{-1 is not a valid weekday})
        expect { described_class.new(name: 'foo', weekday: '8') }.to raise_error(Puppet::Error, %r{8 is not a valid weekday})
      end

      it 'does not support invalid weekday names' do
        expect { described_class.new(name: 'foo', weekday: 'Sar') }.to raise_error(Puppet::Error, %r{Sar is not a valid weekday})
      end

      it 'supports valid multiple values' do
        expect { described_class.new(name: 'foo', weekday: ['0', '1', '6']) }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: ['Mon', 'Wed', 'Friday']) }.not_to raise_error
      end

      it 'does not support multiple values if at least one is invalid' do
        # one invalid
        expect { described_class.new(name: 'foo', weekday: ['0', '1', '8']) }.to raise_error(Puppet::Error, %r{8 is not a valid weekday})
        expect { described_class.new(name: 'foo', weekday: ['Mon', 'Fii', 'Sat']) }.to raise_error(Puppet::Error, %r{Fii is not a valid weekday})
        # two invalid
        expect { described_class.new(name: 'foo', weekday: ['Mos', 'Fii', 'Sat']) }.to raise_error(Puppet::Error, %r{(Mos|Fii) is not a valid weekday})
        # all invalid
        expect { described_class.new(name: 'foo', weekday: ['Mos', 'Fii', 'Saa']) }.to raise_error(Puppet::Error, %r{(Mos|Fii|Saa) is not a valid weekday})
        expect { described_class.new(name: 'foo', weekday: ['-1', '8', '11']) }.to raise_error(Puppet::Error, %r{(-1|8|11) is not a valid weekday})
      end

      it 'supports valid step syntax' do
        expect { described_class.new(name: 'foo', weekday: '*/2') }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: '0-4/2') }.not_to raise_error
      end

      it 'does not support invalid steps' do
        expect { described_class.new(name: 'foo', weekday: '*/A') }.to raise_error(Puppet::Error, %r{\*/A is not a valid weekday})
        expect { described_class.new(name: 'foo', weekday: '*/2A') }.to raise_error(Puppet::Error, %r{\*/2A is not a valid weekday})
        # As it turns out cron does not complaining about steps that exceed the valid range
        # expect { described_class.new(:name => 'foo', :weekday => '*/9' ) }.to raise_error(Puppet::Error, /is not a valid weekday/)
      end

      it 'supports values with leading zeros' do
        expect { described_class.new(name: 'foo', weekday: ['Mon', 'Wed', '05']) }.not_to raise_error
        expect { described_class.new(name: 'foo', weekday: '007') }.not_to raise_error
      end

      it 'does not remove leading zeroes' do
        expect(described_class.new(name: 'foo', weekday: '006')[:weekday]).to eq(['006'])
      end
    end

    describe 'month' do
      it 'supports absent' do
        expect { described_class.new(name: 'foo', month: 'absent') }.not_to raise_error
      end

      it 'supports *' do
        expect { described_class.new(name: 'foo', month: '*') }.not_to raise_error
      end

      it 'translates absent to :absent' do
        expect(described_class.new(name: 'foo', month: 'absent')[:month]).to eq(:absent)
      end

      it 'translates * to :absent' do
        expect(described_class.new(name: 'foo', month: '*')[:month]).to eq(:absent)
      end

      it 'supports valid numeric values' do
        expect { described_class.new(name: 'foo', month: '1') }.not_to raise_error
        expect { described_class.new(name: 'foo', month: '12') }.not_to raise_error
      end

      it 'supports valid months as words' do
        expect(described_class.new(name: 'foo', month: 'January')[:month]).to eq(['1'])
        expect(described_class.new(name: 'foo', month: 'February')[:month]).to eq(['2'])
        expect(described_class.new(name: 'foo', month: 'March')[:month]).to eq(['3'])
        expect(described_class.new(name: 'foo', month: 'April')[:month]).to eq(['4'])
        expect(described_class.new(name: 'foo', month: 'May')[:month]).to eq(['5'])
        expect(described_class.new(name: 'foo', month: 'June')[:month]).to eq(['6'])
        expect(described_class.new(name: 'foo', month: 'July')[:month]).to eq(['7'])
        expect(described_class.new(name: 'foo', month: 'August')[:month]).to eq(['8'])
        expect(described_class.new(name: 'foo', month: 'September')[:month]).to eq(['9'])
        expect(described_class.new(name: 'foo', month: 'October')[:month]).to eq(['10'])
        expect(described_class.new(name: 'foo', month: 'November')[:month]).to eq(['11'])
        expect(described_class.new(name: 'foo', month: 'December')[:month]).to eq(['12'])
      end

      it 'supports valid months as words (3 character short version)' do
        expect(described_class.new(name: 'foo', month: 'Jan')[:month]).to eq(['1'])
        expect(described_class.new(name: 'foo', month: 'Feb')[:month]).to eq(['2'])
        expect(described_class.new(name: 'foo', month: 'Mar')[:month]).to eq(['3'])
        expect(described_class.new(name: 'foo', month: 'Apr')[:month]).to eq(['4'])
        expect(described_class.new(name: 'foo', month: 'May')[:month]).to eq(['5'])
        expect(described_class.new(name: 'foo', month: 'Jun')[:month]).to eq(['6'])
        expect(described_class.new(name: 'foo', month: 'Jul')[:month]).to eq(['7'])
        expect(described_class.new(name: 'foo', month: 'Aug')[:month]).to eq(['8'])
        expect(described_class.new(name: 'foo', month: 'Sep')[:month]).to eq(['9'])
        expect(described_class.new(name: 'foo', month: 'Oct')[:month]).to eq(['10'])
        expect(described_class.new(name: 'foo', month: 'Nov')[:month]).to eq(['11'])
        expect(described_class.new(name: 'foo', month: 'Dec')[:month]).to eq(['12'])
      end

      it 'does not support numeric values out of range' do
        expect { described_class.new(name: 'foo', month: '-1') }.to raise_error(Puppet::Error, %r{-1 is not a valid month})
        expect { described_class.new(name: 'foo', month: '0') }.to raise_error(Puppet::Error, %r{0 is not a valid month})
        expect { described_class.new(name: 'foo', month: '13') }.to raise_error(Puppet::Error, %r{13 is not a valid month})
      end

      it 'does not support words that are not valid months' do
        expect { described_class.new(name: 'foo', month: 'Jal') }.to raise_error(Puppet::Error, %r{Jal is not a valid month})
      end

      it 'does not support single values out of range' do
        expect { described_class.new(name: 'foo', month: '-1') }.to raise_error(Puppet::Error, %r{-1 is not a valid month})
        expect { described_class.new(name: 'foo', month: '60') }.to raise_error(Puppet::Error, %r{60 is not a valid month})
        expect { described_class.new(name: 'foo', month: '61') }.to raise_error(Puppet::Error, %r{61 is not a valid month})
        expect { described_class.new(name: 'foo', month: '120') }.to raise_error(Puppet::Error, %r{120 is not a valid month})
      end

      it 'supports valid multiple values' do
        expect { described_class.new(name: 'foo', month: ['1', '9', '12']) }.not_to raise_error
        expect { described_class.new(name: 'foo', month: ['Jan', 'March', 'Jul']) }.not_to raise_error
      end

      it 'does not support multiple values if at least one is invalid' do
        # one invalid
        expect { described_class.new(name: 'foo', month: ['0', '1', '12']) }.to raise_error(Puppet::Error, %r{0 is not a valid month})
        expect { described_class.new(name: 'foo', month: ['1', '13', '10']) }.to raise_error(Puppet::Error, %r{13 is not a valid month})
        expect { described_class.new(name: 'foo', month: ['Jan', 'Feb', 'Jxx']) }.to raise_error(Puppet::Error, %r{Jxx is not a valid month})
        # two invalid
        expect { described_class.new(name: 'foo', month: ['Jan', 'Fex', 'Jux']) }.to raise_error(Puppet::Error, %r{(Fex|Jux) is not a valid month})
        # all invalid
        expect { described_class.new(name: 'foo', month: ['-1', '0', '13']) }.to raise_error(Puppet::Error, %r{(-1|0|13) is not a valid month})
        expect { described_class.new(name: 'foo', month: ['Jax', 'Fex', 'Aux']) }.to raise_error(Puppet::Error, %r{(Jax|Fex|Aux) is not a valid month})
      end

      it 'supports valid step syntax' do
        expect { described_class.new(name: 'foo', month: '*/2') }.not_to raise_error
        expect { described_class.new(name: 'foo', month: '1-12/3') }.not_to raise_error
      end

      it 'does not support invalid steps' do
        expect { described_class.new(name: 'foo', month: '*/A') }.to raise_error(Puppet::Error, %r{\*/A is not a valid month})
        expect { described_class.new(name: 'foo', month: '*/2A') }.to raise_error(Puppet::Error, %r{\*/2A is not a valid month})
        # As it turns out cron does not complaining about steps that exceed the valid range
        # expect { described_class.new(:name => 'foo', :month => '*/13' ) }.to raise_error(Puppet::Error, /is not a valid month/)
      end

      it 'supports values with leading zeros' do
        expect { described_class.new(name: 'foo', month: ['007', '1', '0012']) }.not_to raise_error
        expect { described_class.new(name: 'foo', month: ['Jan', '04', '0009']) }.not_to raise_error
      end

      it 'does not remove leading zeroes' do
        expect(described_class.new(name: 'foo', month: '09')[:month]).to eq(['09'])
      end
    end

    describe 'monthday' do
      it 'supports absent' do
        expect { described_class.new(name: 'foo', monthday: 'absent') }.not_to raise_error
      end

      it 'supports *' do
        expect { described_class.new(name: 'foo', monthday: '*') }.not_to raise_error
      end

      it 'translates absent to :absent' do
        expect(described_class.new(name: 'foo', monthday: 'absent')[:monthday]).to eq(:absent)
      end

      it 'translates * to :absent' do
        expect(described_class.new(name: 'foo', monthday: '*')[:monthday]).to eq(:absent)
      end

      it 'supports valid single values' do
        expect { described_class.new(name: 'foo', monthday: '1') }.not_to raise_error
        expect { described_class.new(name: 'foo', monthday: '30') }.not_to raise_error
        expect { described_class.new(name: 'foo', monthday: '31') }.not_to raise_error
      end

      it 'does not support non numeric characters' do
        expect { described_class.new(name: 'foo', monthday: 'z23') }.to raise_error(Puppet::Error, %r{z23 is not a valid monthday})
        expect { described_class.new(name: 'foo', monthday: '2z3') }.to raise_error(Puppet::Error, %r{2z3 is not a valid monthday})
        expect { described_class.new(name: 'foo', monthday: '23z') }.to raise_error(Puppet::Error, %r{23z is not a valid monthday})
      end

      it 'does not support single values out of range' do
        expect { described_class.new(name: 'foo', monthday: '-1') }.to raise_error(Puppet::Error, %r{-1 is not a valid monthday})
        expect { described_class.new(name: 'foo', monthday: '0') }.to raise_error(Puppet::Error, %r{0 is not a valid monthday})
        expect { described_class.new(name: 'foo', monthday: '32') }.to raise_error(Puppet::Error, %r{32 is not a valid monthday})
      end

      it 'supports valid multiple values' do
        expect { described_class.new(name: 'foo', monthday: ['1', '23', '31']) }.not_to raise_error
        expect { described_class.new(name: 'foo', monthday: ['31', '23', '1']) }.not_to raise_error
        expect { described_class.new(name: 'foo', monthday: ['1', '31', '23']) }.not_to raise_error
      end

      it 'does not support multiple values if at least one is invalid' do
        # one invalid
        expect { described_class.new(name: 'foo', monthday: ['1', '23', '32']) }.to raise_error(Puppet::Error, %r{32 is not a valid monthday})
        expect { described_class.new(name: 'foo', monthday: ['-1', '12', '23']) }.to raise_error(Puppet::Error, %r{-1 is not a valid monthday})
        expect { described_class.new(name: 'foo', monthday: ['13', '32', '30']) }.to raise_error(Puppet::Error, %r{32 is not a valid monthday})
        # two invalid
        expect { described_class.new(name: 'foo', monthday: ['-1', '0', '23']) }.to raise_error(Puppet::Error, %r{(-1|0) is not a valid monthday})
        # all invalid
        expect { described_class.new(name: 'foo', monthday: ['-1', '0', '32']) }.to raise_error(Puppet::Error, %r{(-1|0|32) is not a valid monthday})
      end

      it 'supports valid step syntax' do
        expect { described_class.new(name: 'foo', monthday: '*/2') }.not_to raise_error
        expect { described_class.new(name: 'foo', monthday: '10-16/2') }.not_to raise_error
      end

      it 'does not support invalid steps' do
        expect { described_class.new(name: 'foo', monthday: '*/A') }.to raise_error(Puppet::Error, %r{\*/A is not a valid monthday})
        expect { described_class.new(name: 'foo', monthday: '*/2A') }.to raise_error(Puppet::Error, %r{\*/2A is not a valid monthday})
        # As it turns out cron does not complaining about steps that exceed the valid range
        # expect { described_class.new(:name => 'foo', :monthday => '*/32' ) }.to raise_error(Puppet::Error, /is not a valid monthday/)
      end

      it 'supports values with leading zeros' do
        expect { described_class.new(name: 'foo', monthday: ['007', '1', '0023']) }.not_to raise_error
        expect { described_class.new(name: 'foo', monthday: '022') }.not_to raise_error
      end

      it 'does not remove leading zeroes' do
        expect(described_class.new(name: 'foo', monthday: '01')[:monthday]).to eq(['01'])
      end
    end

    describe 'special' do
      ['reboot', 'yearly', 'annually', 'monthly', 'weekly', 'daily', 'midnight', 'hourly'].each do |value|
        it "should support the value '#{value}'" do
          expect { described_class.new(name: 'foo', special: value) }.not_to raise_error
        end
      end

      context 'when combined with numeric schedule fields' do
        context "which are 'absent'" do
          [['reboot', 'yearly', 'annually', 'monthly', 'weekly', 'daily', 'midnight', 'hourly'], :absent].flatten.each do |value|
            it "should accept the value '#{value}' for special" do
              expect {
                described_class.new(name: 'foo', minute: :absent, special: value)
              }.not_to raise_error
            end
          end
        end
        context 'which are not absent' do
          ['reboot', 'yearly', 'annually', 'monthly', 'weekly', 'daily', 'midnight', 'hourly'].each do |value|
            it "should not accept the value '#{value}' for special" do
              expect {
                described_class.new(name: 'foo', minute: '1', special: value)
              }.to raise_error(Puppet::Error, %r{cannot specify both a special schedule and a value})
            end
          end
          it "accepts the 'absent' value for special" do
            expect {
              described_class.new(name: 'foo', minute: '1', special: :absent)
            }.not_to raise_error
          end
        end
      end
    end

    describe 'environment' do
      it 'accepts an :environment that looks like a path' do
        expect {
          described_class.new(name: 'foo', environment: 'PATH=/bin:/usr/bin:/usr/sbin')
        }.not_to raise_error
      end

      it "does not accept environment variables that do not contain '='" do
        expect {
          described_class.new(name: 'foo', environment: 'INVALID')
        }.to raise_error(Puppet::Error, %r{Invalid environment setting "INVALID"})
      end

      it "accepts empty environment variables that do not contain '='" do
        expect {
          described_class.new(name: 'foo', environment: 'MAILTO=')
        }.not_to raise_error
      end

      it "accepts 'absent'" do
        expect {
          described_class.new(name: 'foo', environment: 'absent')
        }.not_to raise_error
      end
    end
  end

  describe 'when autorequiring resources' do
    let(:user_bob) { Puppet::Type.type(:user).new(name: 'bob', ensure: :present) }
    let(:user_alice) { Puppet::Type.type(:user).new(name: 'alice', ensure: :present) }
    let(:catalog) { Puppet::Resource::Catalog.new }

    before :each do
      catalog.add_resource user_bob, user_alice
    end

    it 'autorequires the user' do
      resource = described_class.new(name: 'dummy', command: '/usr/bin/uptime', user: 'alice')
      catalog.add_resource resource
      req = resource.autorequire
      expect(req.size).to eq(1)
      expect(req[0].target).to eq(resource)
      expect(req[0].source).to eq(user_alice)
    end
  end

  it 'does not require a command when removing an entry' do
    entry = described_class.new(name: 'test_entry', ensure: :absent)
    expect(entry.value(:command)).to eq(nil)
  end

  it 'defaults to user => root if Etc.getpwuid(Process.uid) returns nil (#12357)' do
    Etc.expects(:getpwuid).returns(nil)
    entry = described_class.new(name: 'test_entry', ensure: :present)
    expect(entry.value(:user)).to eql 'root'
  end
end
