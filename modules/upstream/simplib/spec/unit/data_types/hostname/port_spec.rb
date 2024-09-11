require 'spec_helper'

test_data_type = 'Simplib::Hostname::Port'

singular_item = 'hostname with port'
plural_item = 'hostnames with port'

valid_data = [
  'localhost:443',
  'localhost.localdomain:80',
  'my-domain.com:22',
  'aa.bb:65535',
]

invalid_data = [
  'a',
  'my_domain.com',
  '0.0.0',
  '0.0.0.0',
  '1.2.3.4',
  '1.2.3.4/24',
  '1.2.3.4/255.255.224.0',
  '1.2.3.4:443',
  '[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443',
  '::1',
  '[::1]'
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
