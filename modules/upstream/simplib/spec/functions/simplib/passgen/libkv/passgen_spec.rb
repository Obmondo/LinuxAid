#!/usr/bin/env ruby -S rspec
require 'spec_helper'
require_relative '../crypt_helper'

include CryptHelper

describe 'simplib::passgen::libkv::passgen' do
  let(:key_root_dir) { 'gen_passwd' }
  let(:id) { 'spectest' }
  let(:key) { "#{key_root_dir}/#{id}" }

  let(:default_chars) do
    (("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a).map do|x|
      x = Regexp.escape(x)
    end
  end

  let(:safe_special_chars) do
    ['@','%','-','_','+','=','~'].map do |x|
      x = Regexp.escape(x)
    end
  end

  let(:unsafe_special_chars) do
    (((' '..'/').to_a + ('['..'`').to_a + ('{'..'~').to_a)).map do |x|
      x = Regexp.escape(x)
    end - safe_special_chars
  end
  let(:base64_regex) do
    '^[a-zA-Z0-9+/=]+$'
  end

  after(:each) do
    # This is required for GitLab, because the spec tests are run by a
    # privileged user who ends up creating a global file store in
    # /var/simp/libkv/file/auto_default, instead of a set of per-test,
    # temporary file stores, each within its test-specific Puppet
    # environment.
    #
    # If we wanted to be truly safe from privileged user issues, we would
    # either configure libkv to use the file plugin with an appropriate
    # per-test path, or, convert all the unit test to use rspec-mocks
    # instead of mocha and then use an appropriate pair of
    # `allow(FileUtils).to receive(:mkdir_p).with...` that fail the global
    # file store directory creation but allow other directory creations.
    # (See spec tests in pupmod-simp-libkv).
    #
    call_function('libkv::deletetree', key_root_dir)
  end

  context 'basic password generation' do
    it 'should run successfully with default arguments' do
      result = subject.execute('spectest')
      expect(result.length).to eq 32
      expect(result).to match(/^(#{default_chars.join('|')})+$/)

      # retrieve what has been stored by libkv and validate
      stored_info = call_function('libkv::get', key)
      expect(stored_info['value']['password']).to eq result
      salt = stored_info['value']['salt']
      expect(salt.length).to eq 16
      expect(salt).to match(/^(#{default_chars.join('|')})+$/)
      meta = { 'complexity' => 0, 'complex_only' => false, 'history' => [] }
      expect(stored_info['metadata']).to eq(meta)
    end

    it 'should return a password that is 32 alphanumeric characters long by default' do
      result = subject.execute('spectest')
      expect(result.length).to eql(32)
      expect(result).to match(/^(#{default_chars.join('|')})+$/)
    end

    it 'should work with a String length' do
      result = subject.execute('spectest', {'length' => '16'})
      expect(result.length).to eql(16)
      expect(result).to match(/^(#{default_chars.join('|')})+$/)
    end

    it 'should return a password that is 8 alphanumeric characters long if length is 8' do
      result = subject.execute('spectest', {'length' => 8})
      expect(result.length).to eql(8)
      expect(result).to match(/^(#{default_chars.join('|')})+$/)
    end

    it 'should return a password that is 8 alphanumeric characters long if length is < 8' do
      result = subject.execute('spectest', {'length' => 4})
      expect(result.length).to eql(8)
      expect(result).to match(/^(#{default_chars.join('|')})+$/)
    end

    it 'should return a password that contains "safe" special characters if complexity is 1' do
      result = subject.execute('spectest', {'complexity' => 1})
      expect(result.length).to eql(32)
      expect(result).to match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(safe_special_chars).join('|')})/)
      expect(result).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      # retrieve what has been stored by libkv and validate metadata
      stored_info = call_function('libkv::get', key)
      meta = { 'complexity' => 1, 'complex_only' => false, 'history' => [] }
      expect(stored_info['metadata']).to eq(meta)
    end

    it 'should return a password that only contains "safe" special characters if complexity is 1 and complex_only is true' do
      result = subject.execute('spectest', {'complexity' => 1, 'complex_only' => true})
      expect(result.length).to eql(32)
      expect(result).not_to match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(safe_special_chars).join('|')})/)
      expect(result).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      # retrieve what has been stored by libkv and validate metadata
      stored_info = call_function('libkv::get', key)
      meta = { 'complexity' => 1, 'complex_only' => true, 'history' => [] }
      expect(stored_info['metadata']).to eq(meta)
    end

    it 'should work with a String complexity' do
      result = subject.execute('spectest', {'complexity' => '1'})
      expect(result.length).to eql(32)
      expect(result).to match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(safe_special_chars).join('|')})/)
      expect(result).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      # retrieve what has been stored by libkv and validate metadata
      stored_info = call_function('libkv::get', key)
      meta = { 'complexity' => 1, 'complex_only' => false, 'history' => [] }
      expect(stored_info['metadata']).to eq(meta)
    end

    it 'should return a password that contains all special characters if complexity is 2' do
      result = subject.execute('spectest', {'complexity' => 2})
      expect(result.length).to eql(32)
      expect(result).to match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(unsafe_special_chars).join('|')})/)

      # retrieve what has been stored by libkv and validate metadata
      stored_info = call_function('libkv::get', key)
      meta = { 'complexity' => 2, 'complex_only' => false, 'history' => [] }
      expect(stored_info['metadata']).to eq(meta)
    end

    it 'should return a password that only contains all special characters if complexity is 2 and complex_only is true' do
      result = subject.execute('spectest', {'complexity' => 2, 'complex_only' => true})
      expect(result.length).to eql(32)
      expect(result).to_not match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(unsafe_special_chars).join('|')})/)

      # retrieve what has been stored by libkv and validate metadata
      stored_info = call_function('libkv::get', key)
      meta = { 'complexity' => 2, 'complex_only' => true, 'history' => [] }
      expect(stored_info['metadata']).to eq(meta)
    end
  end

  context 'password generation with history' do
    it 'should return the same password when called multiple times with same options' do
      first_result = subject.execute('spectest', {'length' => 32})
      expect(subject.execute('spectest', {'length' => 32})).to eq (first_result)
      expect(subject.execute('spectest', {'length' => 32})).to eq (first_result)
      stored_info = call_function('libkv::get', key)
      expect(stored_info['metadata']['history']).to be_empty
    end

    it 'should return current password if no password options are specified' do
      # intentionally pick a password with a length different than default length
      result = subject.execute('spectest', {'length' => 64})
      expect(subject.execute('spectest')).to eql(result)
    end

    it 'should return a new password if previous password has different specified length' do
      first_result = subject.execute('spectest', {'length' => 32})
      second_result = subject.execute('spectest', {'length' => 64})
      expect(second_result).to_not eq(first_result)
      expect(second_result.length).to eq(64)
    end

    it 'should return a new password if previous password has different specified complexity' do
      first_result = subject.execute('spectest', {'complexity' => 0})
      second_result = subject.execute('spectest', {'complexity' => 1})
      expect(second_result).to_not eq(first_result)
    end

    it 'should return a new password if previous password has different specified complex_only' do
      first_result = subject.execute('spectest', {'complex_only' => true})
      second_result = subject.execute('spectest', {'complex_only' => false})
      second_result = subject.execute('spectest', {'complexity' => 1})
      expect(second_result).to_not eq(first_result)
    end

    it 'should return the next to last created password if "last" is true' do
      first_result = subject.execute('spectest', {'length' => 32})
      first_stored_info = call_function('libkv::get', key)
      # changing password length forces a new password to be generated
      second_result = subject.execute('spectest', {'length' => 33})
      second_stored_info = call_function('libkv::get', key)
      third_result = subject.execute('spectest', {'length' => 34})
      third_stored_info = call_function('libkv::get', key)
      expect(subject.execute('spectest', {'last' => true})).to eql(second_result)
      expected_history = [
        [second_stored_info['value']['password'], second_stored_info['value']['salt']],
        [first_stored_info['value']['password'], first_stored_info['value']['salt']]
      ]
      expect(third_stored_info['metadata']['history']).to eq(expected_history)
    end

    it 'should return the current password if "last" is true but there is no previous password' do
      result = subject.execute('spectest', {'length' => 32})
      expect(subject.execute('spectest', {'last' => true})).to eql(result)
    end

    it 'should return a new password if "last" is true but there is no current or previous password' do
      result = subject.execute('spectest', {'last' => true})
      expect(result.length).to eql(32)
    end

  end

  context 'password encryption ' do
    # These tests check the resulting modular crypt formatted hash.
    {
      'md5' => {
        "code" => '1',
        "bits" => 128,
        "end_hash" => '$1$badsalt$lpOt58v4EmRjaID6kGO4j.'
      },
      'sha256' => {
        "code" => '5',
        "bits" => 256,
        "end_hash" => '$5$badsalt$FZYRq7gz.KjbTsd1uzm.lhPBvy9LAefLwvRn2PVVd37'
      },
      'sha512' => {
        "code" => '6',
        "bits" => 512,
        "end_hash" => '$6$badsalt$hk7dh/Mz.oPuPZgDkPrNU/WSQOOq6T8PA8FO4mmLkfGdgvyEvqd8HyD5UeD2aYysmczplpo5qkU8RYjX1R6LS0'
      }
    }.each do |hash_selection, object|
      context "when hash == #{hash_selection}" do

        let(:shared_options) do
          {
            'hash' => hash_selection,
            'complexity' => 2
          }
        end

        if File.exist?('/proc/sys/crypto/fips_enabled') &&
            File.open('/proc/sys/crypto/fips_enabled', &:readline)[0].chr == '1' &&
            hash_selection == 'md5'
          puts 'Skipping md5, as not available on this FIPS-compliant server'
        else
          it 'should parse as modular crypt' do
            result = subject.execute('spectest', shared_options);
            expect(parse_modular_crypt(result)).to_not eql(nil)
          end

          it "should use #{object['code']} as the algorithm code" do
            value = parse_modular_crypt(subject.execute('spectest', shared_options));
            expect(value['algorithm_code']).to eql(object['code'])
          end

          it 'should contain a salt of complexity 0' do
            value = parse_modular_crypt(subject.execute('spectest', shared_options));
            expect(value['salt']).to match(/^(#{default_chars.join('|')})+$/)
          end

          it 'should contain a base64 hash' do
            value = parse_modular_crypt(subject.execute('spectest', shared_options));
            expect(value['hash_base64']).to match(/#{base64_regex}/)
          end

          it "should contain a valid #{hash_selection} hash after decoding" do
            result = subject.execute('spectest', shared_options);
            value = parse_modular_crypt(result);
            expect(value['hash_bitlength']).to eql(object['bits'])
          end
        end
      end
    end
  end

  context 'misc errors' do

    it 'fails when password generation times out' do
      Timeout.expects(:timeout).with(30).raises(Timeout::Error, 'Timeout')
      is_expected.to run.with_params('spectest').and_raise_error(RuntimeError,
        /simplib::passgen timed out for 'spectest'!/)
    end

    it 'fails when libkv operation fails' do
      libkv_options = {
        'backend'  => 'oops',
        'backends' => {
          'oops'  => {
            'type' => 'does_not_exist_type',
            'id'   => 'test',
          }
        }
      }

      is_expected.to run.with_params('spectest', {}, libkv_options).
        and_raise_error(ArgumentError,
        /libkv Configuration Error/)
    end
  end


  context 'with password_options parameter errors' do
    it do
      is_expected.to run.with_params('spectest', {'length' => 'oops'}).and_raise_error(
        /Error: Length 'oops' must be an integer/)
    end

    it do
      is_expected.to run.with_params('spectest', {'complexity' => 'oops'}).and_raise_error(
        /Error: Complexity 'oops' must be an integer/)
    end

    it do
      is_expected.to run.with_params('spectest', {'gen_timeout_seconds' => 'oops'}).and_raise_error(
        /Error: Password generation timeout 'oops' must be an integer/)
    end

    it do
      is_expected.to run.with_params('spectest', {'hash' => 'sha1'}).and_raise_error(
        /Error: 'sha1' is not a valid hash/)
    end
  end
end
