require 'spec_helper'

describe 'Ruby provider for node_encrypted_file' do
  let(:resource) { Puppet::Type.type(:node_encrypted_file).new(:path => '/foo') }
  subject { Puppet::Type.type(:node_encrypted_file).provider(:ruby).new(resource) }

  it 'exists? returns true if file exists' do
    File.expects(:file?).with('/foo').returns(true)
    expect(subject.exists?).to eq true
  end

  it 'exists? returns false if file does not exist' do
    File.expects(:file?).with('/foo').returns(false)
    expect(subject.exists?).to eq false
  end

  it 'should write decrypted content to file' do
    Puppet_X::Binford2k::NodeEncrypt.expects(:encrypted?).at_least_once.with('foo').returns(true)
    Puppet_X::Binford2k::NodeEncrypt.expects(:decrypt).with('foo').returns('bar')
    File.expects(:write).with('/foo', 'bar')

    subject.resource[:content] = 'foo'
    subject.create
  end

  it 'should retrieve contents from a file' do
    File.expects(:read).with('/foo').twice.returns('bar')
    expect(subject.content.decrypted_value).to eq 'bar'
    expect(subject.content.to_s).to eq '<<encrypted>>'
  end
end
