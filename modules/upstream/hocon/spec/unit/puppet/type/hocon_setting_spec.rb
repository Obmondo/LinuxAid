require 'puppet'
require 'puppet/type/hocon_setting'
describe Puppet::Type.type(:hocon_setting) do
  let(:resource) do
    Puppet::Type.type(:hocon_setting).new(
      title: 'hocon setting',
      path: '/tmp/hocon.setting',
      setting: 'test_key.master',
      value: 'value',
      type: 'text',
    )
  end

  it 'is ensurable' do
    resource[:ensure] = :present
    expect(resource[:ensure]).to be(:present)
    resource[:ensure] = :absent
    expect(resource[:ensure]).to be(:absent)
  end

  it 'raises an error if an invalid ensure value is passed' do
    expect { resource[:ensure] = 'file' }.to raise_error \
      Puppet::Error, %r{Invalid value "file"}
  end

  it 'accepts a valid type value' do
    valid_types = ['boolean', 'string', 'text', 'number', 'array', 'array_element', 'hash']

    valid_types.each do |t|
      resource[:type] = t
      expect(resource[:type]).to eq(t)
    end
  end

  it 'raises an error with invalid type values when a value is specified' do
    resource[:type] = 'blarg'
    expect { resource[:value] = 4 }.to raise_error \
      Puppet::Error, %r{Type was specified as blarg, but should have been one of 'boolean'}
  end

  it 'accepts valid boolean values' do
    resource[:type] = 'boolean'
    [true, false].each do |val|
      resource[:value] = val
      expect(resource[:value]).to eq([val])
    end
  end

  it 'raises an error with invalid boolean values' do
    resource[:type] = 'boolean'
    expect { resource[:value] = 'not boolean' }.to raise_error \
      Puppet::Error, %r{Type specified as 'boolean' but was String}
  end

  it 'accepts valid string and text values' do
    ['string', 'text'].each do |t|
      resource[:type] = t
      resource[:value] = 'string value'
      expect(resource[:value]).to eq(['string value'])
    end
  end

  it 'raises an error with invalid string and text values' do
    ['string', 'text'].each do |t|
      resource[:type] = t
      expect { resource[:value] = 4 }.to raise_error \
        Puppet::Error, %r{Type specified as #{t} but was (Fixnum|Integer)}
    end
  end

  it 'accepts valid number values' do
    [13, 13.37].each do |t|
      resource[:type]  = 'number'
      resource[:value] = t
      expect(resource[:value]).to eq([t])
    end
  end

  it 'accepts valid number values as a string' do
    {
      '13'    => 13,
      '13.37' => 13.37,
    }.each do |key, val|
      resource[:type]  = 'number'
      resource[:value] = key
      expect(resource[:value].eql?([val])).to be(true)
    end
  end

  it 'raises an error with invalid number values' do
    ['string', '45g'].each do |t|
      resource[:type] = 'number'
      expect { resource[:value] = t }.to raise_error \
        Puppet::Error, %r{Type specified as 'number' but was String}
    end
  end

  it 'accepts valid array values' do
    array = ['foo', 'bar']
    resource[:type]  = 'array'
    resource[:value] = array
    expect(resource[:value]).to eq(array)
  end

  it 'accepts valid hash values' do
    hash = { 'key' => 'value' }
    resource[:type]  = 'hash'
    resource[:value] = hash
    expect(resource[:value]).to eq([hash])
  end

  it 'raises an error with invalid hash values' do
    resource[:type] = 'hash'
    expect { resource[:value] = 4 }.to raise_error \
      Puppet::Error, %r{Type specified as 'hash' but was (Fixnum|Integer)}
  end
end
