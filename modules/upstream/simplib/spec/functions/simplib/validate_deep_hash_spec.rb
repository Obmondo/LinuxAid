require 'spec_helper'

describe 'simplib::validate_deep_hash' do

  context 'with valid 1-level input' do
   let(:ref_hash) do
     {
        'string_value'        => '^\w+$',
        'boolean_true_value'  => '^true|false$',
        'boolean_false_value' => '^true|false$',
        'numeric_value_1'     => '^\d+$',
        'numeric_value_2'     => '^\d+\.\d+$',
        'unused_key'          => '^\w+$'
      }
    end

    let(:test_hash) do
      {
        'string_value'        => 'value',
        'boolean_true_value'  => true,
        'boolean_false_value' => false,
        'numeric_value_1'     => 23,
        'numeric_value_2'     => '4.56'
      }
    end

    it 'validates input containing exact matches of allowed ref types' do
      is_expected.to run.with_params(test_hash, test_hash)
    end

    it 'validates input containing regex matches of allowed ref types' do
      is_expected.to run.with_params(ref_hash, test_hash)
    end

    it 'validates input containing arrays' do
      test_hash_with_array = test_hash.dup
     test_hash_with_array['numeric_value_1'] = [1, 2, 34]
      is_expected.to run.with_params(ref_hash, test_hash_with_array)
    end

    it "skips validation of elements specified by nil or 'nil'" do
      ref_hash_with_nil = ref_hash.dup
      ref_hash_with_nil['string_value'] = nil
      ref_hash_with_nil['numeric_value_1'] = 'nil'
      is_expected.to run.with_params(ref_hash_with_nil, test_hash)
    end
  end

  context 'valid multi-level input' do
    let(:ref_hash) do
      {
        'level1' =>  {
          'string_value_1' => '^\w+$',
          'level2' => {
            'level3' => {
              'boolean_true_value' => '^true|false$',
              'level4' => {
                'boolean_false_value' => '^true|false$',
              },
              'numeric_value_1'=> '^\d+$',
            },
            'numeric_value_2' => '^\d+\.\d+$'
          }
        },
        'string_value_2' => 'value'
      }
    end

    let(:test_hash) do
      {
        'level1' =>  {
          'string_value_1' => 'value1',
          'level2' => {
            'level3' => {
              'boolean_true_value'  => true,
              'level4' => {
                'boolean_false_value' => false,
              },
              'numeric_value_1'     => '23'
            },
            'numeric_value_2'     => 4.56
          }
        },
        'string_value_2' => 'string value 2'
      }
    end

    it 'validates input containing exact matches of allowed ref types' do
      is_expected.to run.with_params(test_hash, test_hash)
    end

    it 'validates input containing regex matches of allowed ref types' do
      is_expected.to run.with_params(ref_hash, test_hash)
    end

    it 'validates input containing arrays' do
      test_hash_with_array = test_hash.dup
      test_hash_with_array['level1']['string_value_1'] = ['one', 'two', 'three']
      is_expected.to run.with_params(ref_hash, test_hash_with_array)
    end

    it "skips validation of elements specified by nil or 'nil'" do
      ref_hash_with_nil = ref_hash.dup
      ref_hash_with_nil['level1']['level2']['level3']['level4']['boolean_false_value'] = nil
      ref_hash_with_nil['level1']['level2']['numeric_value_2'] = 'nil'
      is_expected.to run.with_params(ref_hash_with_nil, test_hash)
    end
  end

  context 'with invalid 1-layer input' do
    let(:ref_hash) do
      {
        'string_value'  => '^\w+$',
        'boolean_value' => '^true|false$',
        'numeric_value' => '^\d+\.\d+$'
       }
    end

    let(:test_hash) do
      {
        'string_value'  => 'value',
        'boolean_value' => true,
        'numeric_value' => 4.56
      }
    end

    it 'rejects ref values with invalid class types' do
      invalid_ref_hash = ref_hash.dup
      invalid_ref_hash['string_value'] = ['a', 'bad', 'ref', 'value']
      is_expected.to run.with_params(invalid_ref_hash, test_hash).and_raise_error(
        /Check for TOP-->string_value has invalid type 'Array'/ )
    end

    it 'rejects input having keys not found in reference hash' do
      input_extra_key = test_hash.dup
      input_extra_key['extra_key'] = 'extra value'
      err_msg = "simplib::validate_deep_hash failed validation:\n" +
        "  TOP-->extra_key not in reference hash"
      is_expected.to run.with_params(ref_hash, input_extra_key).and_raise_error(
        err_msg)
    end

    it 'rejects input not matching reference and reports all failures' do
      invalid_input = test_hash.dup
      invalid_input['string_value'] = 1
      invalid_input['boolean_value'] = 'TRUE'
      invalid_input['numeric_value'] = 'infinity'
      err_msg = "simplib::validate_deep_hash failed validation:\n" +
        "  TOP-->boolean_value 'TRUE' must validate against '/^true|false$/'\n" +
        "  TOP-->numeric_value 'infinity' must validate against '/^\\d+\\.\\d+$/'"

      is_expected.to run.with_params(ref_hash, invalid_input).and_raise_error(
        err_msg )
    end
  end

  context 'invalid multi-level input' do
    let(:ref_hash) do
      {
        'level1' =>  {
          'string_value_1' => '^\w+$',
          'level2' => {
            'level3' => {
              'boolean_true_value' => '^true|false$',
              'level4' => {
                'boolean_false_value' => '^true|false$',
              },
              'numeric_value_1'=> '^\d+$',
            },
            'numeric_value_2' => '^\d+\.\d+$'
          }
        },
        'string_value_2' => 'value'
      }
    end

    let(:test_hash) do
      {
        'level1' =>  {
          'string_value_1' => 'value1',
          'level2' => {
            'level3' => {
              'boolean_true_value'  => true,
              'level4' => {
                'boolean_false_value' => false,
              },
              'numeric_value_1'     => '23'
            },
            'numeric_value_2'     => 4.56
          }
        },
        'string_value_2' => 'string value 2'
      }
    end

    it 'rejects ref values with invalid class types' do
      invalid_ref_hash = ref_hash.dup
      invalid_ref_hash['level1']['string_value_1'] = ['a', 'bad', 'ref', 'value']
      is_expected.to run.with_params(invalid_ref_hash, test_hash).and_raise_error(
        /Check for TOP-->level1-->string_value_1 has invalid type 'Array'/ )
    end

    it 'rejects input having keys not found in reference hash' do
      input_extra_key = test_hash.dup
      input_extra_key['level1']['level2']['extra_key'] = 'extra value'
      err_msg = "simplib::validate_deep_hash failed validation:\n" +
        "  TOP-->level1-->level2-->extra_key not in reference hash"
      is_expected.to run.with_params(ref_hash, input_extra_key).and_raise_error(
        err_msg)
    end

    it 'rejects input not matching reference and reports all failures' do
      invalid_input = test_hash.dup
      invalid_input['level1']['string_value_1'] = {'unexpected' => 'hash'}
      invalid_input['level1']['level2']['numeric_value_2'] = 'not a numeric'
      invalid_input['level1']['level2']['level3']['boolean_true_value'] = 'TRUE'
      invalid_input['level1']['level2']['level3']['level4']['boolean_false_value'] = 'FALSE'

      err_msg = "simplib::validate_deep_hash failed validation:\n" +
        "  TOP-->level1-->string_value_1 should not be a Hash\n" +
        "  TOP-->level1-->level2-->level3-->boolean_true_value 'TRUE' must validate against '/^true|false$/'\n" +
        "  TOP-->level1-->level2-->level3-->level4-->boolean_false_value 'FALSE' must validate against '/^true|false$/'\n" +
        "  TOP-->level1-->level2-->numeric_value_2 'not a numeric' must validate against '/^\\d+\\.\\d+$/'"

      is_expected.to run.with_params(ref_hash, invalid_input).and_raise_error(
        err_msg )
    end
  end

end
