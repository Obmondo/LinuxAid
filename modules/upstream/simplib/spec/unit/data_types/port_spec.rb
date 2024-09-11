require 'spec_helper'

describe 'Simplib::Port', type: :class do
  describe 'valid handling' do
    let(:pre_condition) {%(
      class #{class_name} (
        Simplib::Port $port
      ){ }

      class { '#{class_name}':
        port => #{port}
      }
    )}

    context 'with valid ports' do
      [0,80,1024,65535].each do |port|
        let(:port){ port }

        it "should work with port #{port}" do
          is_expected.to compile
        end
      end
    end

    context 'with invalid ports' do
      [-1,65536,12345678910,'22',true].each do |port|
        let(:port){ port }

        it "should fail on port #{port}" do
          is_expected.to compile.and_raise_error(/parameter 'port' expects/)
        end
      end
    end
  end
end
