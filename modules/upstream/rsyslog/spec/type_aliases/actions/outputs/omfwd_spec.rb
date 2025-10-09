# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omfwd' do
  let(:data) do
    {
      target: '192.168.100.50',
      port: 514,
      protocol: 'tcp',
      networknamespace: 'foo',
      address: '192.168.100.51',
      ipfreebind: 0,
      device: 'eth0',
      tcp_framing: 'traditional',
      tcp_framedelimiter: 152,
      ziplevel: 0,
      'compression.mode' => 'none',
      'compression.stream.flushontxend' => 'off',
      rebindinterval: 600,
      keepalive: 'on',
      'keepalive.probes' => 0,
      'keepalive.interval' => 300,
      'keepalive.time' => 0,
      streamdriver: 'tcp',
      streamdrivermode: 0,
      streamdriverauthmode: 'foo',
      streamdriverpermittedpeers: 'bar',
      resendlastmsgonreconnect: 'on',
      'udp.sendtoall' => 'off',
      'udp.senddelay' => 15,
      gnutlsprioritystring: 'baz'
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
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          protocol: 'foo',
          networknamespace: '',
          device: '',
          tcp_framing: 'bar',
          'compression.mode' => 'double',
          'compression.stream.flushontxend' => true,
          keepalive: false,
          streamdriver: 'udp',
          streamdriverauthmode: '',
          streamdriverpermittedpeers: '',
          resendlastmsgonreconnect: true,
          'udp.sendtoall' => false,
          gnutlsprioritystring: ''
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          port: '600',
          ipfreebind: '0',
          tcp_framedelimiter: 600,
          ziplevel: 10,
          rebindinterval: '15s',
          'keepalive.probes' => '10',
          'keepalive.interval' => '30s',
          'keepalive.time' => '0',
          streamdrivermode: '0',
          'udp.senddelay' => '30m'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad ip address' do
      let(:bad_ip) do
        {
          target: '300.122.32.40',
          address: '400.152.24.666'
        }
      end

      it { is_expected.not_to allow_value(bad_ip) }
    end
  end
end
