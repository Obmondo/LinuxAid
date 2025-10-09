# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omsnmp' do
  let(:data) do
    {
      server: 'localhost',
      port: 121,
      transport: 'tcp',
      version: 0,
      community: 'public',
      trapoid: '1.3.6.1.4.1.19406.1.2.1',
      messageoid: '1.3.6.1.4.1.19406.1.2.1',
      enterpriseoid: '1.3.6.1.4.1.3.1.1',
      specifictype: 0,
      traptype: 0
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
          expected_param[:server] = 'localhost' unless param.to_s == 'server'
          expected_param[:port] = 121 unless param.to_s == 'port'
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          server: '192.16.3.12',
          port: 121,
          transport: false,
          community: '',
          trapoid: 1,
          messageoid: 2,
          enterpriseoid: 3
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          server: '192.16.3.12',
          port: '80',
          version: 3,
          specifictype: '0',
          traptype: 10
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad ip address' do
      let(:bad_ip) do
        {
          server: '300.122.32.',
          port: 121
        }
      end

      it { is_expected.not_to allow_value(bad_ip) }
    end
  end
end
