require 'spec_helper'

describe 'simplib::debug::classtrace' do
  let(:pre_condition) {%{
    class foo { simplib::debug::classtrace() }

    define bar { include foo }

    class baz { bar { 'test': } }

    include baz
  }}

  it {
    Puppet.expects(:warning).with(%(Simplib::Debug::Classtrace:\n    => Class[main]\n    => Class[Baz]\n    => Bar[test]\n    => Class[Foo])).once

    retval = scope.call_function('simplib::debug::classtrace', false)

    expect(retval).to eq(['Class[main]'])
  }
end
