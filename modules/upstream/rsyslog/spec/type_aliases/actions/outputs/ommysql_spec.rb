# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Ommysql' do
  let(:data) do
    {
      server: 'localhost',
      socket: '/var/lib/mysql.sock',
      db: 'database',
      uid: 'user',
      pwd: 'password',
      serverport: 80,
      'mysqlconfig.file' => '/etc/my.cnf',
      'mysqlconfig.section' => 'server',
      template: 't_mysql'
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
          expected_param[:db] = 'database' unless param.to_s == 'db'
          expected_param[:uid] = 'user' unless param.to_s == 'uid'
          expected_param[:pwd] = 'password' unless param.to_s == 'pwd'
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          server: '192.16.3.',
          db: 1,
          uid: 0,
          pwd: '',
          'mysqlconfig.section' => 10,
          template: false
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          serverport: '80'
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
          socket: 'my.sock',
          'mysqlconfig.file' => 'my.cnf'
        }
      end

      it { is_expected.not_to allow_value(bad_path) }
    end
  end
end
