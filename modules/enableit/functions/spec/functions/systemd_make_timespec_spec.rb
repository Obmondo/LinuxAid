require 'spec_helper'

describe 'systemd_make_timespec' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params().and_raise_error(ArgumentError, /expects 1 argument, got none$/) }
  it { is_expected.to run.with_params('two').and_raise_error(ArgumentError, /expects a Hash value, got String/) }
  it { is_expected.to run.with_params(1).and_raise_error(ArgumentError, /expects a Hash value, got Integer/) }

  it {
    is_expected.to run \
      .with_params({
                     'weekday' => ['Mon', 'Tue'],
                     'year' => '*',
                     'month' => '*',
                     'day' => '*',
                     'hour' => '*',
                     'minute' => '*',
                     'second' => '*',
                   }) \
      .and_return 'Mon,Tue *-*-* *:*:*'
  }

  it {
    is_expected.to run \
      .with_params({
                     'year' => '*',
                     'month' => '*',
                     'day' => '*',
                     'hour' => '*',
                     'minute' => '*',
                     'second' => '*',
                   }) \
      .and_return '*-*-* *:*:*'
  }

  it {
    is_expected.to run \
      .with_params({
                     'weekday' => ['Mon'],
                     'year' => [2016,2017],
                     'month' => '*/2',
                     'day' => '*',
                     'hour' => '*',
                     'minute' => '*',
                     'second' => '*',
                   }) \
      .and_return 'Mon 2016,2017-*/2-* *:*:*'
  }

  it {
    is_expected.to run \
      .with_params({
                     'weekday' => 'undef',
                     'year' => [2016,2017],
                     'month' => '*/2',
                     'day' => '*',
                     'hour' => '*',
                     'minute' => '*',
                     'second' => '*',
                   }) \
      .and_return '2016,2017-*/2-* *:*:*'
  }
end
