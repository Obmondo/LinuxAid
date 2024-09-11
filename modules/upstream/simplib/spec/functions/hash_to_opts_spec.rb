require 'spec_helper'

describe 'simplib::hash_to_opts' do

  tests = [
    {
      content: {'iface' => 'eth1'},
      result: '--iface=eth1'
    },
    {
      content: { 'iface' => 'eth1', 'arg2'  => 'junk value' },
      result: '--iface=eth1 --arg2="junk value"'
    },
    {
      content: {'key' => 8},
      result: '--key=8'
    },
    {
      content: {'key' => false},
      result: '--key=false'
    },
    {
      content: {'key' => ['yes',true,1]},
      result: '--key=yes,true,1'
    },
    {
      content: {'key' => :undef},
      result: '--key'
    },
    {
      content: {'key' => nil},
      result: '--key'
    },
  ]


  it { is_expected.to run.with_params() \
    .and_raise_error(/between 1 and 2 arguments, got none/) }

  context 'with default secondary options' do
    tests.each do |params|
      it { is_expected.to run.with_params(params[:content]) \
        .and_return(params[:result]) }
    end
  end

  context 'with some secondary options set' do
    tests.each do |params|
      opts = { 'connector' => ' ' }
      result = params[:result].gsub(/=/,' ')

      it { is_expected.to run.with_params(params[:content],opts) \
        .and_return(result) }
    end
  end

  context 'with all secondary options set' do
    tests.each do |params|
      opts = {
        'connector' => ' ',
        'prefix'    => '-',
        'delimiter' => ':'
      }
      result = params[:result] \
        .gsub(/=/,' ')
        .gsub(/--/,'-')
        .gsub(/,/,':')

      it { is_expected.to run.with_params(params[:content],opts) \
        .and_return(result) }
    end
  end

  context 'with repeat set to repeat' do
    params = { 'key' => ['yes',true,1] }
    opts   = { 'repeat' => 'repeat' }
    result = '--key=yes --key=true --key=1'
    it { is_expected.to run.with_params(params,opts) \
        .and_return(result) }
  end
end
