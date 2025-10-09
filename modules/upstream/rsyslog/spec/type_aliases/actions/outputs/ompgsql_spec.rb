# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Ompgsql' do
  context 'with minimum required valid data' do
    let(:data) do
      {
        db: 'database'
      }
    end

    context 'with server ip address' do
      let(:ip_data) { data.merge(server: '1.1.1.1') }

      it { is_expected.to allow_value(ip_data) }
    end

    context 'with server hostname' do
      let(:name_data) { data.merge(server: 'localhost') }

      it { is_expected.to allow_value(name_data) }
    end

    context 'with server fqdn' do
      let(:fqdn_data) { data.merge(server: 'server.example.com') }

      it { is_expected.to allow_value(fqdn_data) }
    end
  end

  context 'with full valid data' do
    let(:data) do
      {
        server: '1.1.1.1',
        port: 5432,
        db: 'database',
        user: 'postgres',
        pass: 'test1234',
        template: 'template1'
      }
    end

    it { is_expected.to allow_value(data) }
  end

  context 'with invalid data' do
    let(:base_data) do
      {
        server: '1.1.1.1',
        db: 'database'
      }
    end

    context 'bad server' do
      let(:invalid) { base_data.merge(server: '300.1.1.1.') }

      it { is_expected.not_to allow_value(invalid) }
    end

    context 'nil database' do
      let(:invalid) { base_data.merge(db: '') }

      it { is_expected.not_to allow_value(invalid) }
    end

    context 'invalid port' do
      let(:invalid) { base_data.merge(port: 100_000) }

      it { is_expected.not_to allow_value(invalid) }
    end

    context 'invalid user' do
      let(:invalid) { base_data.merge(user: '') }

      it { is_expected.not_to allow_value(invalid) }
    end

    context 'invalid pass' do
      let(:invalid) { base_data.merge(pass: '') }

      it { is_expected.not_to allow_value(invalid) }
    end

    context 'invalid template' do
      let(:invalid) { base_data.merge(template: '') }

      it { is_expected.not_to allow_value(invalid) }
    end
  end
end
