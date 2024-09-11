#!/usr/bin/env ruby -S rspec
require 'spec_helper'
require_relative '../crypt_helper'

include CryptHelper

describe 'simplib::passgen::legacy::passgen' do

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

  # DEBUG NOTES:
  #   Puppet[:vardir] is dynamically created as a tmpdir by the test
  #   framework, when the subject is first created. So if you want
  #   to know what vardir is so you can create/modify files in
  #   that directory as part of the test setup, in the 'it' block,
  #   first create the subject yourself and then retrieve the
  #   vardir value as shown below:
  #
  # it 'does something' do
  #   subject()  # vardir created as a tmpdir for this example block
  #   vardir = Puppet[:vardir]
  #
  #   <pre-seed file content here>
  #
  #   is_expected.to run.with_params('spectest')  # run the function
  #
  # end
  context 'basic password generation' do
    it 'should run successfully with default arguments' do
      result = subject.execute('spectest')

      vardir = Puppet[:vardir]
      passwd_file = File.join(vardir, 'simp', 'environments', 'rp_env',
        'simp_autofiles', 'gen_passwd', 'spectest')
      expect(File.exist?(passwd_file)).to be true
      password = IO.read(passwd_file).chomp
      expect(password).to eq result

      salt_file = File.join(vardir, 'simp', 'environments', 'rp_env',
        'simp_autofiles', 'gen_passwd', 'spectest.salt')
      expect(File.exist?(salt_file)).to be true
      salt = IO.read(salt_file).chomp
      expect(salt.length).to eq 16
      expect(salt).to match(/^(#{default_chars.join('|')})+$/)
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
    end

    it 'should return a password that only contains "safe" special characters if complexity is 1 and complex_only is true' do
      result = subject.execute('spectest', {'complexity' => 1, 'complex_only' => true})
      expect(result.length).to eql(32)
      expect(result).not_to match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(safe_special_chars).join('|')})/)
      expect(result).not_to match(/(#{(unsafe_special_chars).join('|')})/)
    end

    it 'should work with a String complexity' do
      result = subject.execute('spectest', {'complexity' => '1'})
      expect(result.length).to eql(32)
      expect(result).to match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(safe_special_chars).join('|')})/)
      expect(result).not_to match(/(#{(unsafe_special_chars).join('|')})/)
    end

    it 'should return a password that contains all special characters if complexity is 2' do
      result = subject.execute('spectest', {'complexity' => 2})
      expect(result.length).to eql(32)
      expect(result).to match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(unsafe_special_chars).join('|')})/)
    end

    it 'should return a password that only contains all special characters if complexity is 2 and complex_only is true' do
      result = subject.execute('spectest', {'complexity' => 2, 'complex_only' => true})
      expect(result.length).to eql(32)
      expect(result).to_not match(/(#{default_chars.join('|')})/)
      expect(result).to match(/(#{(unsafe_special_chars).join('|')})/)
    end
  end

  context 'password generation with history' do
    it 'should return the same password when called multiple times with same options' do
      first_result = subject.execute('spectest', {'length' => 32})
      expect(subject.execute('spectest', {'length' => 32})).to eq (first_result)
      expect(subject.execute('spectest', {'length' => 32})).to eq (first_result)
    end

    it 'should return current password if no password options are specified' do
      result = subject.execute('spectest', {'length' => 32})
      expect(subject.execute('spectest')).to eql(result)
    end

    it 'should return a new password if previous password has different specified length' do
      first_result = subject.execute('spectest', {'length' => 32})
      second_result = subject.execute('spectest', {'length' => 64})
      expect(second_result).to_not eq(first_result)
      expect(second_result.length).to eq(64)
    end

    it 'should return the next to last created password if "last" is true' do
      first_result = subject.execute('spectest', {'length' => 32})
      second_result = subject.execute('spectest', {'length' => 33})
      third_result = subject.execute('spectest', {'length' => 34})
      expect(subject.execute('spectest', {'last' => true})).to eql(second_result)
    end

    it 'should return the current password if "last" is true but there is no previous password' do
      result = subject.execute('spectest', {'length' => 32})
      expect(subject.execute('spectest', {'last' => true})).to eql(result)
    end

    it 'should return a new password if "last" is true but there is no current or previous password' do
      result = subject.execute('spectest', {'length' => 32})
      expect(result.length).to eql(32)
    end

    it 'should return the modifier_hash password if "last" is true but there is no current or previous password' do
      is_expected.to run.with_params('spectest', {'password' => 'passed-in-password'}).and_return('passed-in-password')
    end

    it 'fixes permissions of entries in key dir' do
      subject()
      vardir = Puppet[:vardir]
      keydir =  File.join(vardir, 'simp', 'environments', 'rp_env',
        'simp_autofiles', 'gen_passwd')
      FileUtils.mkdir_p(keydir)
      user1_passwd_file = File.join(keydir, 'user1')
      File.open(user1_passwd_file, 'w') { |file| file.puts('user1 password') }
      FileUtils.chmod(0644, user1_passwd_file)

      result = subject.execute('user2')

      expect(File.exist?(user1_passwd_file)).to be true
      expect(File.stat(user1_passwd_file).mode.to_s(8)).to eq '100640'
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
        let(:specific_options) do
          {
            'password' => 'reallybadpassword',
            'salt' => 'badsalt',
            'hash' => hash_selection,
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

          it "should return exactly #{object['end_hash']} when salt and password are specified" do
            result = subject.execute('spectest',specific_options)
            expect(result).to eql(object['end_hash'])
          end
        end
      end
    end
  end

  context 'misc errors' do
    it 'fails when keydir cannot be created' do
      if ENV['USER'] == 'root' or ENV['HOME'] == '/root'
        skip("Test can't be run as root")
      end

      subject()
      vardir = Puppet[:vardir]
      autofiles_dir =  File.join(vardir, 'simp', 'environments', 'rp_env',
        'simp_autofiles')
      FileUtils.mkdir_p(autofiles_dir)
      FileUtils.chmod(0550, autofiles_dir)
      is_expected.to run.with_params('spectest').and_raise_error(
        /simplib::passgen: Could not make directory/
      )

      # cleanup so directory can be removed when tmpdir is destroyed
      FileUtils.chmod(0750, autofiles_dir)
    end

    pending 'fails when password generation times out'
    pending 'fails when it finds files/dirs not owned by puppet in the key dir'
  end


  context 'with modifier_hash parameter errors' do
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
