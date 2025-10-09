# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imtcp' do
  let(:data) do
    {
      port: 514,
      address: '127.0.0.1',
      name: 'test',
      ruleset: 't_ruleset',
      supportoctetcountedframing: 'off',
      'ratelimit.interval' => 0,
      'ratelimit.burst' => 60_000,
      listenportfilename: 'foo'
    }
  end

  context 'passes with valid data' do
    it 'passes when passed some basic data' do
      is_expected.to allow_value(data)
    end

    it 'passes with each paramater' do
      req_param = { port: 514 }
      data.each do |param, value|
        is_expected.to allow_value({ param.to_sym => value }.merge!(req_param))
      end
    end
  end
end
