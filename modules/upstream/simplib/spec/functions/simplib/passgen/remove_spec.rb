#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::remove' do
  let(:key_root_dir) { 'gen_passwd' }
  let(:id) { 'my_id' }
  let(:key) { "#{key_root_dir}/#{id}" }
  let(:passwords) { [
    'password for my_id 1',
    'password for my_id 0'
  ] }

  let(:salts) { [
    'salt for my_id 1',
    'salt for my_id 0'
  ] }

  # The bulk of simplib::passgen::remove testing is done in tests for
  # simplib::passgen::legacy::remove and simplib::passgen::libkv::remove.
  # The  primary focus of this test is to spot check that the correct
  # function is called and failures are appropriately reported.

  context 'legacy passgen::remove' do

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
    context 'success cases' do
      it 'should succeed when no password files exist' do
        is_expected.to run.with_params(id)
      end

      it 'should remove all password-related files' do
        subject()
        settings = call_function('simplib::passgen::legacy::common_settings')
        FileUtils.mkdir_p(settings['keydir'])
        password_file = File.join(settings['keydir'], id)
        password_file_last = "#{password_file}.last"
        File.open(password_file, 'w') { |file| file.puts passwords[0] }
        File.open(password_file_last, 'w') { |file| file.puts passwords[1] }

        salt_file = File.join(settings['keydir'], "#{id}.salt")
        salt_file_last = "#{salt_file}.last"
        File.open(salt_file, 'w') { |file| file.puts salts[0] }
        File.open(salt_file_last, 'w') { |file| file.puts salts[1] }

        is_expected.to run.with_params(id)

        expect( File.exist?(password_file) ).to be false
        expect( File.exist?(password_file_last) ).to be false
        expect( File.exist?(salt_file) ).to be false
        expect( File.exist?(salt_file_last) ).to be false
      end
    end

    context 'error cases' do
      it 'fails when a password/salt file cannot be removed' do
        subject()
        settings = call_function('simplib::passgen::legacy::common_settings')
        FileUtils.mkdir_p(settings['keydir'])
        password_file = File.join(settings['keydir'], id)
        File.open(password_file, 'w') { |file| file.puts passwords[0] }

        File.stubs(:unlink).with(password_file).raises(Errno::EACCES, 'file unlink failed')

        is_expected.to run.with_params(id).and_raise_error( RuntimeError,
          /Unable to remove all files:.*#{id}: Permission denied - file unlink failed/m)
      end
    end
  end

  context 'libkv passgen::remove' do
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
      call_function('libkv::deletetree', key_root_dir)
    end

    context 'successful operation' do
      it 'should succeed when password key does not exist' do
        is_expected.to run.with_params(id)
      end

      it 'should remove password key when it exists' do
        # call subject() to make sure test Puppet environment is created
        # before we try to pre-populate the default key/value store with
        # a password
        subject()
        value = { 'password' => passwords[0], 'salt' => salts[0] }
        meta = {
          'complexity' => 0,
          'complex_only' => false,
          'history' => []
        }
        call_function('libkv::put', key, value, meta)

        is_expected.to run.with_params(id)
        expect( call_function('libkv::exists', key) ).to be false
      end
    end

    context 'failures' do
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

        is_expected.to run.with_params( id, libkv_options).
          and_raise_error(ArgumentError, /libkv Configuration Error/)
      end
    end
  end
end
