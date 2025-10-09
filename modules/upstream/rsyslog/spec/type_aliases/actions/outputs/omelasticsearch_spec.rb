# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Actions::Outputs::Omelasticsearch' do
  let(:data) do
    {
      server: 'elasticfoo',
      serverport: 1234,
      healthchecktimeout: 30,
      searchindex: 'bar',
      dynsearchindex: 'off',
      searchtype: 'any',
      dynsearchtype: 'off',
      pipelinename: 'baz',
      dynpipelinename: 'off',
      usehttps: 'on',
      timeout: '30s',
      template: 't_foobar',
      bulkmode: 'on',
      maxbytes: '32m',
      parent: 'blah',
      dynparent: 'off',
      uid: 'user',
      pwd: 'somepass',
      errorfile: '/foo/bar/error/file',
      'tls.cacert' => '/foo/bar/ca.pem',
      'tls.mycert' => '/foo/bar/cert.pem',
      'tls.myprivkey' => '/foo/bar/key.pem',
      bulkid: 'bulk_template',
      dynbulkid: 'on',
      writeoperation: 'create',
      retryfailures: 'on',
      retryruleset: 'foo_ruleset',
      'ratelimit.interval' => 10,
      'ratelimit.burst' => 100
    }
  end

  context 'with valid data' do
    context 'full data' do
      it { is_expected.to allow_value(data) }
    end

    context 'full data with server array' do
      let(:data) { { server: %w[foo bar baz] } }

      it { is_expected.to allow_value(data) }
    end

    context 'testing pattern types' do
      context 'maxsize pattern' do
        %w[k K m M g G t T].each do |size|
          it { is_expected.to allow_value(maxbytes: "64#{size}") }
        end
      end

      context 'timeout pattern' do
        %w[ms s m].each do |unit|
          it { is_expected.to allow_value(timeout: "10#{unit}") }
        end
      end
    end
  end

  context 'with invalid data' do
    context 'bad strings' do
      let(:bad_data) do
        {
          server: false,
          searchindex: 10,
          searchtype: false,
          pipelinename: 40,
          template: true,
          parent: false,
          uid: 10,
          pwd: 400,
          bulkid: 30,
          retryruleset: true
        }
      end

      it { is_expected.not_to allow_value(bad_data) }
    end

    context 'bad numbers' do
      let(:bad_data) do
        {
          serverport: '80',
          healthchecktimeout: '30',
          'ratelimit.interval' => '100',
          'ratelimit.burst' => '30'
        }
      end

      it { is_expected.not_to allow_value(bad_data) }
    end

    context 'invalid paths' do
      let(:bad_data) do
        {
          errorfile: 'testing/path',
          'tls.cacert' => 'ca.pem',
          'tls.mycert' => 'cert.pem',
          'tls.myprivkey' => 'key.pem'
        }
      end

      it { is_expected.not_to allow_value(bad_data) }
    end

    context 'invalid enumerators' do
      let(:bad_data) do
        {
          dynsearchindex: false,
          dynsearchtype: true,
          dynpipelinename: false,
          asyncrepl: false,
          usehttps: true,
          bulkmode: false,
          dynparent: true,
          dynbulkid: false,
          writeoperation: 'delete',
          retryfailures: false
        }
      end

      it { is_expected.not_to allow_value(bad_data) }
    end
  end
end
