require 'spec_helper'
require 'puppet'

provider_class = Puppet::Type.type(:hocon_setting).provider(:ruby)
describe provider_class do
  include PuppetlabsSpec::Files

  let(:tmpfile) { tmpfilename('hocon_setting_test.conf') }
  let(:emptyfile) { tmpfilename('hocon_setting_test_empty.conf') }

  let(:common_params) do
    {
      title: 'hocon_setting_ensure_present_test',
      path: tmpfile,
    }
  end

  def validate_file(expected_content, tmp = tmpfile)
    _tmpcontent = File.read(tmp)
    expect(File.read(tmp)).to eq(expected_content)
  end

  before :each do
    File.open(tmpfile, 'w') do |fh|
      fh.write(orig_content)
    end
    File.open(emptyfile, 'w') do |fh|
      fh.write('')
    end
  end

  # rubocop:disable Layout/IndentHeredoc
  context 'array_element' do
    let(:orig_content) do
      <<-EOS
test_key_1: [
  {
    foo: foovalue
    bar: barvalue
    master: true
  }
,
  {
    foo: foovalue2
    baz: bazvalue
    url: "http://192.168.1.1:8080"
  }
,
  {
    foo: foovalue3
  }
]
      EOS
    end

    it 'adds a new element to the array' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1', value: [{ 'foo' => 'foovalue3' }, { 'bar' => 'barvalue3' }], type: 'array_element',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
      provider.create
      validate_file(
        <<-EOS
test_key_1: [
    {
        "bar": "barvalue",
        "foo": "foovalue",
        "master": true
    }
,
    {
        "baz": "bazvalue",
        "foo": "foovalue2",
        "url": "http://192.168.1.1:8080"
    }
,
    {
        "foo": "foovalue3"
    }
,
    {
        "bar": "barvalue3"
    }

]
      EOS
      )
    end

    it 'removes elements from the array' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1', ensure: 'absent', value: { 'foo' => 'foovalue3' }, type: 'array_element',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
      provider.destroy
      validate_file(
        <<-EOS
test_key_1: [
    {
        "bar": "barvalue",
        "foo": "foovalue",
        "master": true
    }
,
    {
        "baz": "bazvalue",
        "foo": "foovalue2",
        "url": "http://192.168.1.1:8080"
    }

]
      EOS
      )
    end

    it 'adds an array element even if the target setting does not yet exist' do
      resource = Puppet::Type::Hocon_setting.new(
        common_params.merge(setting: 'test_key_2',
                            ensure: 'present',
                            value: { 'foo' => 'foovalue3' },
                            type: 'array_element'),
      )
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      validate_file(
        <<-EOS
test_key_1: [
  {
    foo: foovalue
    bar: barvalue
    master: true
  }
,
  {
    foo: foovalue2
    baz: bazvalue
    url: "http://192.168.1.1:8080"
  }
,
  {
    foo: foovalue3
  }
]
test_key_2: [

    {

        "foo": "foovalue3"

    }



]
      EOS
      )
    end

    it 'adds an array element even if the target setting is not an array' do
      File.open(tmpfile, 'a') do |fh|
        fh.write('test_key_2: 3')
      end
      resource = Puppet::Type::Hocon_setting.new(
        common_params.merge(setting: 'test_key_2',
                            ensure: 'present',
                            value: { 'foo' => 'foovalue3' },
                            type: 'array_element'),
      )
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      validate_file(
        <<-EOS
test_key_1: [
  {
    foo: foovalue
    bar: barvalue
    master: true
  }
,
  {
    foo: foovalue2
    baz: bazvalue
    url: "http://192.168.1.1:8080"
  }
,
  {
    foo: foovalue3
  }
]
test_key_2: [
    {
        "foo": "foovalue3"
    }

]
      EOS
      )
    end

    it 'converts a scalar key to a single element array when type is set' do
      File.open(tmpfile, 'w') do |fh|
        fh.write('ennui: yes')
      end
      resource = Puppet::Type::Hocon_setting.new(
        common_params.merge(setting: 'ennui',
                            ensure: 'present',
                            value: ['yes'],
                            type: 'array'),
      )
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      expect(provider.exists?).to be true
      validate_file(
        <<-EOS
ennui: [
    "yes"
]
EOS
      )
    end

    it 'converts to a scalar from single element array when type is unset' do
      content = <<-EOS
ennui: [
    "yes"
]
EOS
      File.open(tmpfile, 'w') do |fh|
        fh.write(content)
      end
      resource = Puppet::Type::Hocon_setting.new(
        common_params.merge(setting: 'ennui',
                            ensure: 'present',
                            value: ['yes']),
      )
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      expect(provider.exists?).to be true
      validate_file("ennui: \"yes\"\n")
    end
  end

  context 'when ensuring that a setting is present' do
    let(:orig_content) do
      <<-EOS
# This is a comment
test_key_1: {
// This is also a comment
  foo: foovalue

  bar: barvalue
  master: true
}

test_key_2: {

  foo: foovalue2
  baz: bazvalue
  url: "http://192.168.1.1:8080"
}

"test_key:3": {
  foo: bar
}
    #another comment
// yet another comment
foo: bar
      EOS
    end

    it 'adds a missing setting to the correct map' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.yahoo', value: 'yippee',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      validate_file(
        <<-EOS
# This is a comment
test_key_1: {
// This is also a comment
  foo: foovalue

  bar: barvalue
  master: true
  yahoo: "yippee"
}

test_key_2: {

  foo: foovalue2
  baz: bazvalue
  url: "http://192.168.1.1:8080"
}

"test_key:3": {
  foo: bar
}
    #another comment
// yet another comment
foo: bar
      EOS
      )
    end

    it 'modifies an existing setting with a different value' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_2.baz', value: 'bazvalue2',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
      provider.value = 'bazvalue2'
      validate_file(
        <<-EOS
# This is a comment
test_key_1: {
// This is also a comment
  foo: foovalue

  bar: barvalue
  master: true
}

test_key_2: {

  foo: foovalue2
  baz: "bazvalue2"
  url: "http://192.168.1.1:8080"
}

"test_key:3": {
  foo: bar
}
    #another comment
// yet another comment
foo: bar
      EOS
      )
    end

    it 'is able to handle settings with non alphanumbering settings' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_2.url', value: 'http://192.168.0.1:8080',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
      expect(provider.value).to eq(['http://192.168.1.1:8080'])
      provider.value = 'http://192.168.0.1:8080'

      validate_file(
        <<-EOS
# This is a comment
test_key_1: {
// This is also a comment
  foo: foovalue

  bar: barvalue
  master: true
}

test_key_2: {

  foo: foovalue2
  baz: bazvalue
  url: "http://192.168.0.1:8080"
}

"test_key:3": {
  foo: bar
}
    #another comment
// yet another comment
foo: bar
      EOS
      )
    end

    it 'recognizes an existing setting with the specified value' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_2.baz', value: 'bazvalue',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
    end

    it 'adds a new map if the path contains a non-existent map' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_4.huzzah', value: 'shazaam',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      validate_file(
        <<-EOS
# This is a comment
test_key_1: {
// This is also a comment
  foo: foovalue

  bar: barvalue
  master: true
}

test_key_2: {

  foo: foovalue2
  baz: bazvalue
  url: "http://192.168.1.1:8080"
}

"test_key:3": {
  foo: bar
}
    #another comment
// yet another comment
foo: bar
test_key_4: {
  huzzah: "shazaam"
}
      EOS
      )
    end

    it 'adds a new map if no maps exists' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.setting1', value: 'helloworld', path: emptyfile,
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      validate_file("test_key_1: {\n  setting1: \"helloworld\"\n}\n", emptyfile)
    end

    it 'is able to handle variables of boolean type' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: false,
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to be(false)
    end

    it 'is able to handle variables of integer type' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: 12,
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to be(12)
    end

    it 'is able to handle variables of float type' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: 12.24,
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to be(12.24)
    end

    it 'is able to handle arrays' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: [1, 2, 3, 4],
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value).to eql([1, 2, 3, 4])
    end

    it 'is able to handle maps' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: { 'a' => 1, 'b' => 2 },
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to eql('a' => 1, 'b' => 2)
    end

    it 'treats a single-element array as a single value if no value type is specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: [12],
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to be(12)
    end

    it 'treats a single-element array as a single-element array if value_type is specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: [12], type: 'array',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value).to eql([12])
    end

    it 'allows setting the exact text of a value in the file' do
      text = "{\n  # a comment\n  a : b\n}"
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: text, type: 'text',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      validate_file(
        <<-EOS
# This is a comment
test_key_1: {
// This is also a comment
  foo: foovalue

  bar: barvalue
  master: {
    # a comment
    a : b
  }
}

test_key_2: {

  foo: foovalue2
  baz: bazvalue
  url: "http://192.168.1.1:8080"
}

"test_key:3": {
  foo: bar
}
    #another comment
// yet another comment
foo: bar
      EOS
      )
    end
  end

  context 'when dealing with settings in the top level' do
    let(:orig_content) do
      <<-EOS
# This is a comment
foo=blah
"test_key_1" {
    # yet another comment
    foo="http://192.168.1.1:8080"
}
      EOS
    end

    it "adds a missing setting if it doesn't exist" do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'bar', value: 'yippee',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      validate_file(<<-EOS
# This is a comment
foo=blah
"test_key_1" {
    # yet another comment
    foo="http://192.168.1.1:8080"
}
bar: "yippee"
      EOS
                   )
    end

    it 'modifies an existing setting with a different value' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'foo', value: 'yippee',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
      expect(provider.value[0]).to eq('blah')
      provider.value = 'yippee'
      validate_file(<<-EOS
# This is a comment
foo="yippee"
"test_key_1" {
    # yet another comment
    foo="http://192.168.1.1:8080"
}
      EOS
                   )
    end

    it 'recognizes an existing setting with the specified value' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'foo', value: 'blah',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
    end
  end

  context 'when the first line of the file is a section' do
    let(:orig_content) do
      <<-EOS
"test_key_2" {
    foo="http://192.168.1.1:8080"
}
      EOS
    end

    it 'is able to add a setting to the top-level map' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'foo', value: 'yippee',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      validate_file(<<-EOS
"test_key_2" {
    foo="http://192.168.1.1:8080"
}
foo: "yippee"
      EOS
                   )
    end
  end

  context 'when ensuring that a setting is absent' do
    let(:orig_content) do
      <<-EOS
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key_3" {
    subby=bar
}
EOS
    end

    it 'removes a setting that exists' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.foo', ensure: 'absent',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be true
      provider.destroy
      # rubocop:disable Layout/TrailingWhitespace - Validate fails without trailing whitespace
      validate_file(<<-EOS
"test_key_1" {
    # This is also a comment
    
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key_3" {
    subby=bar
}
      EOS
                   )
    end
    # rubocop:enable Layout/TrailingWhitespace

    it 'does nothing for a setting that does not exist' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_3.foo', ensure: 'absent',
      ))
      provider = described_class.new(resource)
      expect(provider.exists?).to be false
      provider.destroy
      validate_file(<<-EOS
"test_key_1" {
    # This is also a comment
    foo=foovalue
    bar=barvalue
    master=true
}
"test_key_2" {
    foo=foovalue2
    baz=bazvalue
    url="http://192.168.1.1:8080"
}
"test_key_3" {
    subby=bar
}
      EOS
                   )
    end
  end

  context 'when validating a value type' do
    let(:orig_content) { '' }

    it "throws when type is 'number' but value is not" do
      expect {
        Puppet::Type::Hocon_setting.new(common_params.merge(
                                          setting: 'foo', type: 'number', value: 'abcdefg',
        ))
      }.to raise_error
    end

    it "throws when type is 'boolean' but value is not" do
      expect {
        Puppet::Type::Hocon_setting.new(common_params.merge(
                                          setting: 'foo', type: 'boolean', value: 'abcdefg',
        ))
      }.to raise_error
    end

    it "throws when type is 'hash' but value is not" do
      expect {
        Puppet::Type::Hocon_setting.new(common_params.merge(
                                          setting: 'foo', type: 'hash', value: 'abcdefg',
        ))
      }.to raise_error
    end

    it "throws when type is 'string' but value is not" do
      expect {
        Puppet::Type::Hocon_setting.new(common_params.merge(
                                          setting: 'foo', type: 'string', value: 12,
        ))
      }.to raise_error
    end

    it "throws when type is 'text' but value is not" do
      expect {
        Puppet::Type::Hocon_setting.new(common_params.merge(
                                          setting: 'foo', type: 'text', value: 12,
        ))
      }.to raise_error
    end

    it 'throws when type is a non-valid string' do
      expect {
        Puppet::Type::Hocon_setting.new(common_params.merge(
                                          setting: 'foo', type: 'invalid', value: 'abcdefg',
        ))
      }.to raise_error
    end

    it 'is able to handle value false with boolean type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: false, type: 'boolean',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to be(false)
    end

    it 'is able to handle value true with boolean type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: true, type: 'boolean',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to be(true)
    end

    it 'is able to handle an integer value with number type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: 12, type: 'number',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0].eql?(12)).to be(true)
    end

    it 'is able to handle a float value with number type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: 13.37, type: 'number',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0].eql?(13.37)).to be(true)
    end

    it 'is able to handle an Integer string value with number type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: '12', type: 'number',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0].eql?(12)).to be(true)
    end

    it 'is able to handle a Float string value with number type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: '13.37', type: 'number',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0].eql?(13.37)).to be(true)
    end

    it 'is able to handle string value with string type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: 'abc', type: 'string',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to eql('abc')
    end

    it 'is able to handle hash value with hash type specified' do
      resource = Puppet::Type::Hocon_setting.new(common_params.merge(
                                                   setting: 'test_key_1.master', value: { 'a' => 'b' }, type: 'hash',
      ))
      provider = described_class.new(resource)
      provider.create
      expect(provider.exists?).to be true
      expect(provider.value[0]).to eql('a' => 'b')
    end
  end
end
