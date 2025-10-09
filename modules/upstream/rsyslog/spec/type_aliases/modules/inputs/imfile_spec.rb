# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Modules::Inputs::Imfile' do
  let(:data) do
    {
      mode: 'inotify',
      readtimeout: 300,
      timeoutgranularity: 'on',
      sortfiles: 'off',
      pollinginterval: 60
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
