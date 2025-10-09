# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imrelp' do
  let(:data) do
    {
      port: 514,
      address: '127.0.0.1',
      name: 'test',
      ruleset: 't_ruleset',
      maxdatasize: '10k',
      tls: 'on',
      'tls.compression' => 'on',
      'tls.dhbits' => 1024,
      'tls.permittedpeer' => %w[test test2 test3],
      'tls.authmode' => 'fingerprint',
      'tls.cacert' => 'SAsdvassdertew',
      'tls.mycert' => 'asdvsaweasdfaa',
      'tls.myprivkey' => 'sadfvrhthfg',
      'tls.prioritystring' => 'expert_setting',
      keepalive: 'on',
      'keepalive.probes' => 10,
      'keepalive.interval' => 300,
      'keepalive.time' => 30,
      oversizemode: 'truncate'
    }
  end

  context 'valid values' do
    it 'passes with pass data hash' do
      is_expected.to allow_value(data)
    end
  end
end
