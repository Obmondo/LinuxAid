require 'spec_helper'

describe 'simplib::debug::inspect' do
  let(:pre_condition) {%{
    $foo = 'test_value'

    simplib::debug::inspect($foo)

    class test {
      $bar = 'other value'

      simplib::debug::inspect($bar)
    }

    include 'test'
  }}

  it {
    Puppet.expects(:warning).with(%(Simplib::Debug::Inspect: Type => 'String' Content => '"test_value"')).once
    Puppet.expects(:warning).with(%(Simplib::Debug::Inspect: Type => 'String' Content => '"other value"' Location: ':6')).once
    Puppet.expects(:warning).with(%(Simplib::Debug::Inspect: Type => 'String' Content => '"foo"')).once

    retval = scope.call_function('simplib::debug::inspect', 'foo')

    expect(retval).to eq({
      :type        => String,
      :content     => '"foo"',
      :module_name => '',
      :file        => nil,
      :line        => nil
    })
  }
end
