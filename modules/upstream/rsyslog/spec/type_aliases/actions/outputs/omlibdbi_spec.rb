# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omlibdbi' do
  let(:data) do
    {
      driver: 'firebird',
      server: 'localhost',
      uid: 'user',
      pwd: 'password',
      db: 'database',
      template: 't_db'
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          driver: 'database3',
          server: '300.12.3.',
          user: 0,
          pwd: '',
          db: 10,
          template: ''
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end
  end
end
