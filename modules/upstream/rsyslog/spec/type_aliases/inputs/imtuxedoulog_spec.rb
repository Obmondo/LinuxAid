# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imtuxedoulog' do
  let(:data) do
    {
      ulogbase: '/foo/bar/path',
      tag: 'test',
      facility: 'kern',
      severity: 'info',
      persiststateinterval: 0,
      maxlinesatonce: 100,
      maxsubmitatonce: 1024
    }
  end

  context 'passes with valid values' do
    it 'passes with default samples' do
      is_expected.to allow_value(data)
    end

    it 'each individual optional param' do
      req_params = {
        ulogbase: '/foo/bar/path',
        tag: 'test'
      }
      data.each do |param, value|
        is_expected.to allow_value({ param.to_sym => value }.merge!(req_params))
      end
    end
  end
end
