#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen' do
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

  # The bulk of simplib::passgen testing is done in tests for
  # simplib::passgen::legacy::passgen and simplib::passgen::libkv::passgen.
  # The primary focus of this test is to spot check that the correct
  # function is called and failures are appropriately reported.


  context 'legacy passgen' do
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

      it 'should return a password that is 8 alphanumeric characters long if length is 8' do
        result = subject.execute('spectest', {'length' => 8})
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

      it 'should return a password that contains all special characters if complexity is 2' do
        result = subject.execute('spectest', {'complexity' => 2})
        expect(result.length).to eql(32)
        expect(result).to match(/(#{default_chars.join('|')})/)
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

  context 'libkv passgen' do
    let(:hieradata){ 'simplib_passgen_libkv' }

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
      call_function('libkv::deletetree', 'gen_passwd')
    end

    context 'basic password generation' do
      it 'should run successfully with default arguments' do
       result = subject.execute('spectest')
       expect(result.length).to eq 32
       expect(result).to match(/^(#{default_chars.join('|')})+$/)

       # retrieve what has been stored by libkv and validate
       stored_info = call_function('libkv::get', 'gen_passwd/spectest')
       expect(stored_info['value']['password']).to eq result
       salt = stored_info['value']['salt']
       expect(salt.length).to eq 16
       expect(salt).to match(/^(#{default_chars.join('|')})+$/)
       meta = { 'complexity' => 0, 'complex_only' => false, 'history' => [] }
       expect(stored_info['metadata']).to eq(meta)
     end

     it 'should return a password that is 8 alphanumeric characters long if length is 8' do
       result = subject.execute('spectest', {'length' => 8})
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
        stored_info = call_function('libkv::get', 'gen_passwd/spectest')
        meta = { 'complexity' => 1, 'complex_only' => false, 'history' => [] }
        expect(stored_info['metadata']).to eq(meta)
      end

      it 'should return a password that contains all special characters if complexity is 2' do
        result = subject.execute('spectest', {'complexity' => 2})
        expect(result.length).to eql(32)
        expect(result).to match(/(#{default_chars.join('|')})/)
        expect(result).to match(/(#{(unsafe_special_chars).join('|')})/)

        # retrieve what has been stored by libkv and validate metadata
        stored_info = call_function('libkv::get', 'gen_passwd/spectest')
        meta = { 'complexity' => 2, 'complex_only' => false, 'history' => [] }
        expect(stored_info['metadata']).to eq(meta)
      end
    end

    context 'password generation with history' do
      it 'should return the same password when called multiple times with same options' do
        first_result = subject.execute('spectest', {'length' => 32})
        expect(subject.execute('spectest', {'length' => 32})).to eq (first_result)
        expect(subject.execute('spectest', {'length' => 32})).to eq (first_result)
        stored_info = call_function('libkv::get', 'gen_passwd/spectest')
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

      it 'should return the next to last created password if "last" is true' do
        first_result = subject.execute('spectest', {'length' => 32})
        # changing password length forces a new password to be generated
        second_result = subject.execute('spectest', {'length' => 33})
        third_result = subject.execute('spectest', {'length' => 34})
        expect(subject.execute('spectest', {'last' => true})).to eql(second_result)
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

    context 'misc errors' do
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
end
