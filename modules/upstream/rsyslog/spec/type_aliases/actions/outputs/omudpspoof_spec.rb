# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omudpspoof' do
  let(:data) do
    {
      target: 'localhost',
      port: 514,
      sourcetemplate: 't_source',
      'sourceport.start' => 32_000,
      'sourceport.end' => 33_000,
      mtu: 1500,
      template: 't_udp_spoof'
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
          expected_param[:target] = 'localhost' unless param.to_s == 'target'
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          target: 'localhost',
          sourcetemplate: false,
          template: false
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          target: 'localhost',
          port: '514',
          'sourceport.start' => 70_000,
          'sourceport.end' => 71_000,
          mtu: '1500'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad ip address' do
      let(:bad_ip) do
        {
          target: '300.122.32.'
        }
      end

      it { is_expected.not_to allow_value(bad_ip) }
    end
  end
end
