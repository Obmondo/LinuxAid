# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Modules::Inputs::Imjournal' do
  let(:data) do
    {
      persiststateinterval: 10,
      statefile: '/var/log/statefile',
      'ratelimit.interval' => 600,
      'ratelimit.burst' => 20_000,
      ignorepreviousmessage: 'off',
      defaultseverity: 'notice',
      defaultfacility: 'kern',
      usepidfromsystem: 'off',
      usepid: 'both',
      ignorenonvalidstatefile: 'on',
      workaroundjournalbug: 'on'
    }
  end

  context 'when passed base data' do
    it 'receives data and passes' do
      is_expected.to allow_value(data)
    end

    it 'receives individual params and passes' do
      data.each do |param, value|
        is_expected.to allow_value(param.to_sym => value)
      end
    end
  end
end
