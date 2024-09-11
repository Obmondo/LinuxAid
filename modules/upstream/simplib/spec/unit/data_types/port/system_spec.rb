require 'spec_helper'

test_data_type = 'Simplib::Port::System'

describe test_data_type, type: :class do
  describe 'valid handling' do
    let(:pre_condition) {%(
      class #{class_name} (
        #{test_data_type} $param
      ){ }

      class { '#{class_name}':
        param => #{param}
      }
    )}

    context 'with valid ports' do
      [1,80,1024].each do |param|
        let(:param){ param }

        it "should work with port #{param}" do
          is_expected.to compile
        end
      end
    end

    context 'with invalid ports' do
      [0,1025,'22',true].each do |param|
        let(:param){ param }

        it "should fail on port #{param}" do
          is_expected.to compile.and_raise_error(/parameter 'param' expects/)
        end
      end
    end
  end
end
