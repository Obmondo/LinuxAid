# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omrelp' do
  let(:data) do
    {
      target: '10.1.1.25',
      port: 514,
      template: 't_relp',
      timeout: 300,
      'conn.timeout' => 60,
      rebindinterval: 30,
      windowsize: 10,
      tls: 'on',
      'tls.compression' => 'off',
      'tls.permittedpeer' => %w[host1 host2 host3],
      'tls.automode' => 'name',
      'tls.cacert' => '/var/cert/ca.pem',
      'tls.mycert' => '/var/cert/cert.pem',
      'tls.myprivkey' => '/var/cert/key.pem',
      'tls.prioritystring' => 'urgent',
      localclientip: '192.168.1.1'
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'individual parameters' do
      it 'is valid' do
        data.each do |param, value|
          expected_param = { param.to_sym => value }
          expected_param[:target] = 'localhost' unless param.to_s == 'target'
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          template: true,
          tls: false,
          'tls.compression' => true,
          'tls.permittedpeer' => [0, 1, 2],
          'tls.automode' => 'foo',
          'tls.prioritystring' => 10
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          port: '600',
          timeout: '300',
          'conn.timeout' => '10s',
          rebindinterval: '5m',
          windowsize: '50'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad ip address' do
      let(:bad_ip) do
        {
          target: '300.122.32.',
          localclientip: '192.233..1'
        }
      end

      it { is_expected.not_to allow_value(bad_ip) }
    end

    context 'bad path' do
      let(:bad_path) do
        {
          'tls.cacert' => 'ca.pem',
          'tls.mycert' => 'cert.pem',
          'tls.myprivkey' => 'key.pem'
        }
      end

      it { is_expected.not_to allow_value(bad_path) }
    end

    context 'bad array' do
      let(:bad_array) do
        {
          'tls.permittedpeer' => 'host1'
        }
      end

      it { is_expected.not_to allow_value(bad_array) }
    end
  end
end
