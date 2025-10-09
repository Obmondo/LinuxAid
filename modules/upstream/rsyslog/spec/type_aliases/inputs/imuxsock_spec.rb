# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imuxsock' do
  let(:data) do
    {
      ruleset: 'r_socket',
      ignoretimestamp: 'off',
      ignoreownmessages: 'on',
      flowcontrol: 'on',
      'ratelimit.interval' => 600,
      'ratelimit.burst' => 60_000,
      'ratelimit.severity' => 1,
      usepidfromsystem: 'on',
      usesystimestamp: 'on',
      createpath: 'on',
      socket: 'foo',
      hostname: 'localhost',
      annotate: 'off',
      parsetrusted: 'on',
      unlink: 'off',
      usespecialparser: 'off',
      parsehostname: 'on'
    }
  end

  context 'when passed default sample data' do
    it 'allows the values' do
      is_expected.to allow_value(data)
    end

    it 'allows the values when passed individually' do
      data.each do |param, value|
        is_expected.to allow_value(param.to_sym => value)
      end
    end
  end
end
