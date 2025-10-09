# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omfile' do
  let(:data) do
    {
      file: '/var/log/file.log',
      dynafile: 'filename',
      template: 't_omfile',
      closetimeout: 15_000,
      dynafilecachesize: 512,
      ziplevel: 0,
      veryrobustzip: 'off',
      flushinterval: 600,
      asyncwriting: 'on',
      flushontxend: 'off',
      iobuffersize: '64M',
      dirowner: 'root',
      dirownernum: 0,
      dirgroup: 'root',
      dirgroupnum: 0,
      fileowner: 'root',
      fileownernum: 0,
      filegroup: 'root',
      filegroupnum: 0,
      filecreatemode: '0600',
      dircreatemode: '0700',
      failonchownfailure: 'on',
      createdirs: 'on',
      sync: 'on',
      'sig.provider' => 'ksi_ls12',
      'cry.provider' => 'gcry'
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
          dynafile: '',
          template: false,
          veryrobustzip: true,
          asyncwriting: 'true',
          flushontxend: false,
          iobuffersize: 512,
          dirowner: 0,
          dirgroup: 0,
          fileowner: 0,
          filegroup: 0,
          filecreatemode: '+rwx',
          dircreatemode: '+rwx',
          failonchownfailure: true,
          createdirs: true,
          sync: true,
          'sig.provider' => 'foo',
          'cry.provider' => 'bar'
        }
      end

      it { is_expected.not_to allow_value(bad_strings) }
    end

    context 'bad integers' do
      let(:bad_int) do
        {
          closetimeout: '600',
          dynafilecachesize: '15M',
          ziplevel: 'tarball',
          flushinterval: '15s',
          dirownernum: '0',
          dirgroupnum: '0',
          fileownernum: '0',
          filegroupnum: '0'
        }
      end

      it { is_expected.not_to allow_value(bad_int) }
    end

    context 'bad path' do
      let(:bad_path) { { file: 'file' } }

      it { is_expected.not_to allow_value(bad_path) }
    end
  end
end
