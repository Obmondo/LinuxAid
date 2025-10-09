# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omprog' do
  let(:data) do
    {
      template: 't_prog',
      binary: '/usr/bin/cat',
      confirmmessages: 'on',
      confirmtimeout: 300,
      reportfailures: 'on',
      usetransactions: 'off',
      begintransactionmark: 'start',
      committransactionmark: 'commit',
      output: '/var/log/prog/output.log',
      filecreatemode: '0644',
      'hup.signal' => 'USR1',
      signalonclose: 'on',
      closetimeout: 120,
      killunresponsive: 'on',
      forcesingleinstance: 'off'
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
          expected_param[:binary] = '/usr/bin/cat' unless param.to_s == 'binary'
          is_expected.to allow_value(expected_param)
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_strings) do
        {
          binary: '/usr/bin/cat',
          template: false,
          confirmmessages: true,
          reportfailures: false,
          usetransactions: true,
          begintransactionmark: 10,
          committransactionmark: false,
          filecreatemode: '+rwx',
          'hup.signal' => 'foo',
          signalonclose: false,
          killunresponsive: false,
          forcesingleinstance: true
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          binary: '/usr/bin/cat',
          confirmtimeout: '10m',
          closetimeout: '1h'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad path' do
      let(:bad_path) do
        {
          binary: 'cat',
          output: 'output.log'
        }
      end

      it { is_expected.not_to allow_value(bad_path) }
    end
  end
end
