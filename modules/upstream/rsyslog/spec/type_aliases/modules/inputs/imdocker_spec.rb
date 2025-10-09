# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Modules::Inputs::Imdocker' do
  let(:data) do
    {
      dockerapiunixsockaddr: '/var/run/docker.sock',
      apiversionstr: 'v1.39',
      pollinginterval: 60,
      listcontaineroptions: 'all=1',
      getcontainerlogoptions: 'timestamp=0&follow=1&stdout=1&stderr=1&tail=1',
      retrievenewlogsfromstart: 1,
      defaultfacility: 'kern',
      defaultseverity: 'debug',
      escapelf: 'off'
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
