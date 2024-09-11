require 'spec_helper'

describe Puppet::Type.type(:node_encrypted_file) do
  subject { Puppet::Type.type(:node_encrypted_file).new(:path => '/foo') }

  it 'should accept ensure' do
    subject[:ensure] = :present
    expect(subject[:ensure]).to eq :present
  end

  it 'should require that path be absolute' do
    expect {
      Puppet::Type.type(:node_encrypted_file).new(:path => 'foo')
    }.to raise_error(Puppet::Error, /Paths must be fully qualified/)
  end

  it 'should accept encrypted contents' do
    Puppet_X::Binford2k::NodeEncrypt.expects(:encrypted?).at_least_once.with('foo').returns(true)
    Puppet_X::Binford2k::NodeEncrypt.expects(:decrypt).with('foo').returns('bar')

    subject[:content] = 'foo'
    expect(subject[:content].to_s).to eq '<<encrypted>>'
    expect(subject[:content].decrypted_value).to eq 'bar'
  end

  it 'should refuse plain text contents' do
    expect {
      Puppet::Type.type(:node_encrypted_file).new(:path => '/foo', :content => 'foo')
    }.to raise_error(Puppet::Error, /Pass only encrypted ciphertext/)
  end
end
