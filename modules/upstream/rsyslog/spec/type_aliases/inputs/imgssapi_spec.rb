# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imgssapi' do
  let(:data) do
    {
      inputgssserverrun: 1514,
      inputgssserverservicename: 'foo',
      inputgssserverpermitplaintcp: 'on',
      inputgssservermaxsessions: 200,
      inputgssserverkeepalive: 'off',
      inputgsslistenportfilename: 514
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'individual parameters' do
      it 'is valid' do
        data.each do |param, value|
          is_expected.to allow_value(param.to_sym => value)
        end
      end
    end
  end

  context 'with invalid data' do
    let(:bad_data) do
      {
        inputgssserverrun: 123_456,
        inputgssserverservicename: '',
        inputgssserverpermitplaintcp: true,
        inputgssservermaxsessions: '200',
        inputgssserverkeepalive: false,
        inputgsslistenportfilename: 234_567
      }
    end

    it 'fails' do
      bad_data.each do |param, value|
        is_expected.not_to allow_value(param.to_sym => value)
      end
    end
  end
end
