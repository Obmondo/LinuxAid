require 'spec_helper'
require 'puppet_x/binford2k/node_encrypt'

describe "node_encrypt::file" do
#
# TODO: I don't know why this spec makes other specs barf. :(
#
  context "ensuring present" do
    let(:node) { 'testhost.example.com' }
    let(:title) { '/tmp/test' }
    let(:params) { {
      :ensure  => 'file',
      :owner   => 'root',
      :mode    => '0644',
      :content => 'foobar'
    } }

#    before(:each) { scope.expects(:node_encrypt).with('foobar','testhost.example.com').returns('encrypted') }
#
#     NameError:
#       undefined local variable or method `scope' for #<RSpec::ExampleGroups::NodeEncryptFile::EnsuringPresent:0x007fda61e9bc20>
#
# This does not work according to docs, so build it manually.
# https://github.com/rodjek/rspec-puppet#accessing-the-parser-scope-where-the-function-is-running

    if Puppet.version[0] == '3'
      before(:each) do
        Puppet::Parser::Functions.newfunction(:node_encrypt, :type => :rvalue) { |args|
          raise ArgumentError, 'expected foobar' unless args[0] == 'foobar'
          'encrypted'
        }
      end
    else
      let(:pre_condition) do
        'function node_encrypt($data) { return "encrypted" }'
      end
    end

    it { should contain_file('/tmp/test').with({
      :ensure  => 'file',
      :owner   => 'root',
      :mode    => '0644',
    }).without_content() }

    it { should contain_node_encrypted_file('/tmp/test')
      .with_content('encrypted')
      .that_comes_before('File[/tmp/test]')
    }
  end

  context "should accept pre-encrypted content" do
    let(:title) { '/tmp/test' }
    let(:params) { {
      :ensure            => 'file',
      :owner             => 'root',
      :mode              => '0644',
      :encrypted_content => 'encrypted'
    } }

    it { should contain_node_encrypted_file('/tmp/test')
      .with_content('encrypted')
      .that_comes_before('File[/tmp/test]')
    }
  end

  context "ensure absent" do
    let(:title) { '/tmp/test' }
    let(:params) { { :ensure => 'absent' } }
    it { should contain_file('/tmp/test').with_ensure('absent') }
    it { should_not contain_node_encrypted_file('/tmp/test') }
  end

end
