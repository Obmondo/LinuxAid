require 'spec_helper'

shared_examples 'simplib::inspect()' do ||
  it { is_expected.to run.with_params(input_array).and_return(return_value) }
end

describe 'simplib::inspect' do
  context 'when default output_type is used' do
    let(:pre_condition) {%{
      $foo = 'test_value'
    }}

    it {
      is_expected.to run.with_params('foo')
      expect(catalogue.resource('Notify[DEBUG_INSPECT_foo]')).not_to be_nil

      resource = catalogue.resource('Notify[DEBUG_INSPECT_foo]')
      expected_msg = <<EOM
Type => String
Content =>
"test_value"
EOM
      expect(resource[:message]).to eq expected_msg.chomp
    }
  end

  context 'when yaml output_type is used' do
    let(:pre_condition) {%{
      $foo = ['a', {'b' => 'c'} ]
    }}

    it {
      is_expected.to run.with_params('foo', 'yaml')

      resource = catalogue.resource('Notify[DEBUG_INSPECT_foo]')

      expected_msg= <<EOM
Type => Array
Content =>
---
- a
- b: c
EOM
      expect(resource[:message]).to eq expected_msg
    }
  end

  context 'when oneline_json output_type is used' do
    let(:pre_condition) {%{
      $foo = ['a', {'b' => 'c'} ]
    }}

    it {
      is_expected.to run.with_params('foo', 'oneline_json')

      resource = catalogue.resource('Notify[DEBUG_INSPECT_foo]')

      expected_msg = 'Type => Array Content => ["a",{"b":"c"}]'
      expect(resource[:message]).to eq expected_msg.chomp
    }
  end
end
# vim: set expandtab ts=2 sw=2:
