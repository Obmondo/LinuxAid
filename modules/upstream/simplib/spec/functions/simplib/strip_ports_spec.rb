require 'spec_helper'

describe 'simplib::strip_ports' do
  context 'when called with hostname variations' do
    let(:args) do
      [
        'http://some.domain.net',
        'http://localhost.my.domain:8989',
        'https://localhost.my.domain:8990',
        'fuu.bar.baz',
        'my.example.net:900',
        'my.example.net:700'
      ]
    end

    let(:expected) do
      [
        'some.domain.net',
        'localhost.my.domain',
        'fuu.bar.baz',
        'my.example.net'
      ]
    end

    it { is_expected.to run.with_params(args).and_return(expected) }
  end

  context 'when called with IPv4 variations' do
    let(:args) do
      [
        'rsync://127.0.0.1:1234',
        '5.6.7.8',
        '9.10.11.12:900',
        '9.10.11.12:700'
      ]
    end

    let(:expected) do
      [
        '127.0.0.1',
        '5.6.7.8',
        '9.10.11.12'
      ]
    end

    it { is_expected.to run.with_params(args).and_return(expected) }
  end


  context 'when called with IPv6 variations' do
    let(:args) do
      [
        'http://[2001:db8:1f70::999:de8:7648:001]:100',
        'http://[2001:db8:1f70::999:de8:7648:002]',
        '[2001:db8:1f70::bbb:de8:7648:003]',
        '[2001:db8:1f70::999:de8:7648:004]:100'
      ]
    end

    let(:expected) do
      [
      '[2001:db8:1f70::999:de8:7648:001]',
      '[2001:db8:1f70::999:de8:7648:002]',
      '[2001:db8:1f70::bbb:de8:7648:003]',
      '[2001:db8:1f70::999:de8:7648:004]'
      ]
    end

    it { is_expected.to run.with_params(args).and_return(expected) }
  end
end
