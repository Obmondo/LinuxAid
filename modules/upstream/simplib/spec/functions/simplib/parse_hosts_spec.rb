require 'spec_helper'

describe 'simplib::parse_hosts' do
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
      {
        'some.domain.net' => {
          :ports => [],
          :protocols => {
            'http' => []
          }
        },
        'localhost.my.domain' => {
          :ports => ['8989','8990'],
          :protocols => {
            'http'  => ['8989'],
            'https' => ['8990']
          }
        },
        'fuu.bar.baz' => {
          :ports     => [],
          :protocols => {}
        },
        'my.example.net' => {
          :ports => ['700','900'],
          :protocols=>{}
        }
      }
    end

    it { is_expected.to run.with_params(args).and_return(expected) }
  end

  context 'when called with IPv4 variations' do
    let(:args) do
      [
        'http://1.2.3.4',
        'http://127.0.0.1:8989',
        'https://127.0.0.1:8990',
        '5.6.7.8',
        '9.10.11.12:900',
        '9.10.11.12:700'
      ]
    end

    let(:expected) do
      {
        '1.2.3.4' => {
          :ports => [],
          :protocols => {
            'http' => []
          }
        },
        '127.0.0.1' => {
          :ports => ['8989','8990'],
          :protocols => {
            'http'  => ['8989'],
            'https' => ['8990']
          }
        },
        '5.6.7.8' => {
          :ports     => [],
          :protocols => {}
        },
        '9.10.11.12' => {
          :ports => ['700','900'],
          :protocols=>{}
        }
      }
    end

    it { is_expected.to run.with_params(args).and_return(expected) }
  end

  context 'when called with IPv6 variations' do
    let(:args) do
      [
        'http://[2001:db8:1f70::999:de8:7648:001]:100',
        'https://[2001:db8:1f70::999:de8:7648:001]:200',
        'http://[2001:db8:1f70::999:de8:7648:002]',
        '[2001:db8:1f70::bbb:de8:7648:003]',
        '[2001:db8:1f70::999:de8:7648:004]:100',
        'http://2001:db8:1f70::999:de8:7648:005',
        '2001:db8:1f70::999:de8:7648:006'
      ]
    end

    let(:expected) do
      {
        '[2001:db8:1f70::999:de8:7648:001]' => {
          :ports => ['100','200'],
          :protocols => {
            'http' => ['100'],
            'https' => ['200']
          }
        },
        '[2001:db8:1f70::999:de8:7648:002]' => {
          :ports => [],
          :protocols => {
            'http' => []
          }
        },
        '[2001:db8:1f70::bbb:de8:7648:003]' => {
          :ports => [],
          :protocols => {}
        },
        '[2001:db8:1f70::999:de8:7648:004]' => {
          :ports => ['100'],
          :protocols => {}
        },
        '[2001:db8:1f70::999:de8:7648:005]' => {
          :ports => [],
          :protocols => {
            'http' => []
          }
        },
        '[2001:db8:1f70::999:de8:7648:006]' => {
          :ports => [],
          :protocols => {}
        }
      }
    end

    it { is_expected.to run.with_params(args).and_return(expected) }
  end

  context 'when called with invalid input' do
    it { is_expected.to run.with_params([]).and_raise_error(ArgumentError) }
    it { is_expected.to run.with_params(['']).and_raise_error(ArgumentError) }
  end
end
