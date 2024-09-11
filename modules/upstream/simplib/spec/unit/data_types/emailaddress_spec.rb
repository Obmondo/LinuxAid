require 'spec_helper'

describe 'Simplib::EmailAddress', type: :class do
  describe 'valid handling' do
    let(:pre_condition) {%(
      class #{class_name} (
        Simplib::EmailAddress $param
      ){ }

      class { '#{class_name}':
        param => '#{param}'
      }
    )}

    context 'with valid addresses' do
      [
        'foo@bar.baz',
        'foo@bar',
        'foo@bar-baz.com',
        'foobar@bar-baz.com',
        'foo+bar@bar-baz.com',
        'foo.bar@bar-baz.com'
      ].each do |param|
        let(:param){ param }

        it "should accept #{param}" do
          is_expected.to compile
        end
      end
    end

    context 'with invalid addresses' do
      [ 'foo' ].each do |param|
        let(:param){ param }

        it "should accept #{param}" do
          is_expected.to compile.and_raise_error(/parameter 'param' expects/)
        end
      end
    end
  end
end
