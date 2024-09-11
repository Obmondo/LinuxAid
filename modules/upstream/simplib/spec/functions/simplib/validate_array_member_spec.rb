require 'spec_helper'

describe 'simplib::validate_array_member' do
  context 'with single input' do
    describe 'validates input contained in array' do
      it { is_expected.to run.with_params('foo',['foo','bar']) }
      it { is_expected.to run.with_params(1, [1, 2]) }
      it { is_expected.to run.with_params(true, [true, false, 'yes', 'no']) }
      it { is_expected.to run.with_params('foo',['FOO','BAR'],'i') }
    end

    describe 'rejects input not contained in array' do
      it do
        is_expected.to run.with_params('foo',['FOO','BAR']).and_raise_error(
         /'\["FOO", "BAR"\]' does not contain 'foo'/ )
      end

      it do
        is_expected.to run.with_params(1, [2, 3]).and_raise_error(
         /'\[2, 3\]' does not contain '1'/ )
      end

      it do
        is_expected.to run.with_params(true, ['yes', 'no']).and_raise_error(
         /'\["yes", "no"\]' does not contain 'true'/ )
      end
    end
  end

  context 'with array input' do
    describe 'validates input contained in array' do
      it { is_expected.to run.with_params(['foo', 'baz'],['foo', 'bar', 'baz']) }
      it { is_expected.to run.with_params([3, 2], [1, 2, 3]) }
      it { is_expected.to run.with_params([true, 'yes'], [true, false, 'yes', 'no']) }
      it { is_expected.to run.with_params(['foo', 'baz'],['FOO', 'BAR', 'BAZ'], 'i') }
    end

    describe 'rejects input not contained in array' do
      it do
        is_expected.to run.with_params(['foo', 'baz'],['FOO', 'BAR', 'BAZ'],).and_raise_error(
         /'\["FOO", "BAR", "BAZ"\]' does not contain '\["foo", "baz"\]'/ )
      end

      it do
        is_expected.to run.with_params([2, 4], [2, 3]).and_raise_error(
         /'\[2, 3\]' does not contain '\[2, 4\]'/ )
      end

      it do
        is_expected.to run.with_params([true, false], ['yes', 'no']).and_raise_error(
         /'\["yes", "no"\]' does not contain '\[true, false\]'/ )
      end
    end
  end
end
