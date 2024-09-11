require 'spec_helper'

test_data_type = 'Simplib::Syslog::Facility'

singular_item = 'facility'
plural_item = 'facilities'

valid_data = [
  'KERN',
  'LOCAL6',
  'LOG_KERN',
  'LOG_LOCAL6',
  'kern',
  'local6'
]

invalid_data = [
  'BOB',
  'NOTICE'
]

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

    context "with valid #{plural_item}" do
      valid_data.each do |data|
        context "with #{singular_item} #{data}" do
          let(:param){ data.is_a?(String) ? "'#{data}'" : data }

          it 'should compile' do
            is_expected.to compile
          end
        end
      end
    end

    context "with invalid #{plural_item}" do
      invalid_data.each do |data|
        context "with #{singular_item} #{data}" do
          let(:param){
            data.is_a?(String) ? "'#{data}'" : data
          }

          it 'should fail to compile' do
            is_expected.to compile.and_raise_error(/parameter 'param'/)
          end
        end
      end
    end
  end
end
