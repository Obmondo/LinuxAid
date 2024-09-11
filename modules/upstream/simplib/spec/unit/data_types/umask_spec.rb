require 'spec_helper'

describe 'Simplib::Umask', type: :class do
  describe 'valid handling' do
    let(:pre_condition) {%(
      class #{class_name} (
        Simplib::Umask $param
      ){ }

      class { '#{class_name}':
        param => '#{param}'
      }
    )}

    context 'with valid umask' do
      [
        '0000',
        '0240',
        '1111'
      ].each do |param|
        let(:param){ param }

        it "should accept #{param}" do
          is_expected.to compile
        end
      end
    end

    context 'with invalid umask' do
      [
        '12345',
        'bob'
      ].each do |param|
        let(:param){ param }

        it "should reject #{param}" do
          is_expected.to compile.and_raise_error(/parameter 'param' expects/)
        end
      end
    end
  end
end
