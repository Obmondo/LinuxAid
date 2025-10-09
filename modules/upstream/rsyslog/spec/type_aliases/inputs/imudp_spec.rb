# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imudp' do
  let(:data) do
    {
      address: '127.0.0.1',
      port: 514,
      ipfreebind: 0,
      device: 'eth0',
      ruleset: 'r_udp',
      'ratelimit.interval' => 0,
      'ratelimit.burst' => 60_000,
      name: 'foo',
      'name.appendport' => 'on',
      defaulttz: '-05:00',
      rcvbufsize: 0
    }
  end

  context 'when passed base data' do
    it 'receives data and passes' do
      is_expected.to allow_value(data)
    end

    it 'receives individual params and passes' do
      req_params = { port: 514 }
      data.each do |param, value|
        is_expected.to allow_value({ param.to_sym => value }.merge!(req_params))
      end
    end
  end
end
