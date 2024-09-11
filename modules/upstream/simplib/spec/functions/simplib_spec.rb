require 'spec_helper'
$: << File.join(File.dirname(__FILE__), '..', '..', 'lib')

require 'puppetx/simp/simplib'

describe 'PuppetX::SIMP::Simplib' do
  context 'PuppetX::SIMP::Simplib.hostname?' do
    it 'returns true for hostname without domain' do
      expect(PuppetX::SIMP::Simplib.hostname?('myhost')).to eq true
    end

    it 'returns true for fully-qualified hostname' do
      expect(PuppetX::SIMP::Simplib.hostname?('my-host.test.local')).to eq true
    end

    it 'returns true for hostname followed by :<number>' do
      expect(PuppetX::SIMP::Simplib.hostname?('myhost:80')).to eq true
    end

    it 'returns true for hostname followed by /<number>' do
      expect(PuppetX::SIMP::Simplib.hostname?('myhost/80')).to eq true
    end

    it 'returns false for nil' do
      expect(PuppetX::SIMP::Simplib.hostname?(nil)).to eq false
    end

    it 'returns false when special characters are present' do
      expect(PuppetX::SIMP::Simplib.hostname?('my:host.test.local')).to eq false
    end

    it 'returns false when starts with dot' do
      expect(PuppetX::SIMP::Simplib.hostname?('.host.test.local')).to eq false
    end

    it 'returns false when ends with dot' do
      expect(PuppetX::SIMP::Simplib.hostname?('host.test.local.')).to eq false
    end

    it 'returns false when starts with dash' do
      expect(PuppetX::SIMP::Simplib.hostname?('-host.test.local')).to eq false
    end

    it 'returns false when ends with dash' do
      expect(PuppetX::SIMP::Simplib.hostname?('host.test.local-')).to eq false
    end

    it 'returns false when contains space' do
      expect(PuppetX::SIMP::Simplib.hostname?('host test.local')).to eq false
    end

    # this abides by RFC 1123, but would not be used in real systems
    it 'returns true for an IP address' do
      expect(PuppetX::SIMP::Simplib.hostname?('1.2.3.4')).to eq true
    end
  end

  context 'PuppetX::SIMP::Simplib.hostname_only?' do
    it 'returns true for hostname without domain' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('myhost')).to eq true
    end

    it 'returns true for fully-qualified hostname' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('my-host.test.local')).to eq true
    end

    it 'returns false for hostname followed by :<number>' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('myhost:80')).to eq false
    end

    it 'returns false for hostname followed by /<number>' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('myhost/80')).to eq false
    end

    it 'returns false for nil' do
      expect(PuppetX::SIMP::Simplib.hostname_only?(nil)).to eq false
    end

    it 'returns false when special characters are present' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('my:host.test.local')).to eq false
    end

    it 'returns false when starts with dot' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('.host.test.local')).to eq false
    end

    it 'returns false when ends with dot' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('host.test.local.')).to eq false
    end

    it 'returns false when starts with dash' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('-host.test.local')).to eq false
    end

    it 'returns false when ends with dash' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('host.test.local-')).to eq false
    end

    it 'returns false when contains space' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('host test.local')).to eq false
    end

    # this abides by RFC 1123, but would not be used in real systems
    it 'returns true for an IPv4 address' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('1.2.3.4')).to eq true
    end

    it 'returns false for an IPv4 CIDR address' do
      expect(PuppetX::SIMP::Simplib.hostname_only?('1.2.3.0/24')).to eq false
    end
  end

  context 'PuppetX::SIMP::Simplib.split_port' do
    it 'extracts nothing from nil' do
      expect(PuppetX::SIMP::Simplib.split_port(nil)).to eq [nil, nil]
    end

    it 'extracts nothing from empty string' do
      expect(PuppetX::SIMP::Simplib.split_port('')).to eq [nil, nil]
    end

    it 'extracts hostname and port' do
      expect(PuppetX::SIMP::Simplib.split_port('myhost.name:5656')).to eq ['myhost.name', '5656']
    end

    it 'extracts IPv4 address and port' do
      expect(PuppetX::SIMP::Simplib.split_port('1.2.3.4:255')).to eq ['1.2.3.4', '255']
    end

    it 'extracts IPv4 quad-dotted address without port' do
      expect(PuppetX::SIMP::Simplib.split_port('1.2.3.4')).to eq ['1.2.3.4', nil]
    end

    it 'extracts IPv4 CIDR address' do
      expect(PuppetX::SIMP::Simplib.split_port('1.2.3.0/24')).to eq ['1.2.3.0/24', nil]
    end

    it 'extracts IPv6 address and port' do
      expect(PuppetX::SIMP::Simplib.split_port('[2001:0db8:85a3:0000:0000:8a2e:0370]:7334')).to eq ['[2001:0db8:85a3:0000:0000:8a2e:0370]', '7334']
    end

    it 'extracts IPv6 address and port' do
      expect(PuppetX::SIMP::Simplib.split_port('[2001:0db8:85a3:0000:0000:8a2e:0370]:')).to eq ['[2001:0db8:85a3:0000:0000:8a2e:0370]', nil]
    end

    it 'extracts IPv6 address without port' do
      expect(PuppetX::SIMP::Simplib.split_port('2001:0db8:85a3:0000:0000:8a2e:0370')).to eq ['[2001:0db8:85a3:0000:0000:8a2e:0370]', nil]
    end

    it 'extracts IPv6 CIDR address' do
      expect(PuppetX::SIMP::Simplib.split_port('2001:0db8:a::/64')).to eq ['2001:0db8:a::/64', nil]
    end
  end
end
