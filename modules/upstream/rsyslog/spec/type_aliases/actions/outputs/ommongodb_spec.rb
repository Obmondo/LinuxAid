# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Ommongodb' do
  let(:data) do
    {
      uristr: 'mongo://string',
      ssl_cert: '/var/cert/cert.pem',
      ssl_ca: '/var/cert/ca.pem',
      db: 'database',
      collection: 'collection',
      allowed_error_codes: %w[11000 47],
      template: 't_mongo',
      server: 'localhost',
      serverported: 57,
      uid: 'user',
      pwd: 'password'
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
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          uristr: '',
          db: 1,
          collection: 2,
          allowed_error_codes: [10, 4],
          template: false,
          uid: 0,
          pwd: ''
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          serverported: '80'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad ip address' do
      let(:bad_ip) do
        {
          server: '300.122.32.'
        }
      end

      it { is_expected.not_to allow_value(bad_ip) }
    end

    context 'bad path' do
      let(:bad_path) do
        {
          ssl_cert: 'cert.pem',
          ssl_ca: 'ca.pem'
        }
      end

      it { is_expected.not_to allow_value(bad_path) }
    end
  end
end
