# frozen_string_literal: true

require 'spec_helper'

describe 'Rsyslog::Inputs::Imptcp' do
  let(:data) do
    {
      port: 514,
      discardtruncatedmsg: 'off',
      fileowner: 'foo',
      filegroup: 'bar',
      fileownernum: 10,
      filegroupnum: 10,
      filecreatemode: '0644',
      failonchownfailure: 'off',
      unlink: 'off',
      name: 'test',
      ruleset: 't_ruleset',
      maxframesize: 1024,
      address: '127.0.0.1',
      addtlframedelimiter: 1,
      supportoctetcountetframing: 'on',
      notifyonconnectionclose: 'off',
      notifyonconnectionopen: 'on',
      keepalive: 'on',
      'keepalive.probes' => 10,
      'keepalive.interval' => 600,
      'keepalive.time' => 120,
      'ratelimit.interval' => 300,
      'ratelimit.burst' => 30,
      'compression.mode' => 'none',
      flowcontrol: 'off',
      multiline: 'on',
      'framing.delimiter.regex' => '^test$',
      socketbacklog: 0,
      defaulttz: 'chicago',
      'framingfix.cisco.asa' => 'on',
      listenportfilename: 'test'
    }
  end

  context 'valid data' do
    context 'default samples' do
      it 'passes' do
        is_expected.to allow_value(data)
      end

      it 'passes with path and not port/address' do
        %w[port address].each { |k| data.delete(k.to_sym) }
        data[:path] = '/foo/bar/log'
        is_expected.to allow_value(data)
      end
    end

    context 'individual param test' do
      it 'loops and tests each param' do
        data[:port] = 514
        data[:address] = '127.0.0.1'
        data.each do |param, value|
          is_expected.to allow_value(param => value)
        end
      end
    end
  end
end
