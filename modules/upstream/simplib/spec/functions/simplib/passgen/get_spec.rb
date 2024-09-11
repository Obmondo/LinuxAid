#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::get' do
  let(:key_root_dir) { 'gen_passwd' }
  let(:id) { 'my_id' }
  let(:key) { "#{key_root_dir}/#{id}" }
  let(:password) { 'password for my_id 2' }
  let(:salt) { 'salt for my_id 2' }
  let(:complexity) { 0 }
  let(:complex_only) { false }
  let(:history) { [
    [ 'password for my_id 1', 'salt for my_id 1'],
    [ 'password for my_id 0', 'salt for my_id 0']
  ] }

  # The bulk of simplib::passgen::get testing is done in tests for
  # simplib::passgen::legacy::get and simplib::passgen::libkv::get.
  # The  primary focus of this test is to spot check that the correct
  # function is called and failures are appropriately reported.

  context 'legacy passgen::get' do
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
    context 'successes' do
      it 'should return {} when password does not exist' do
        is_expected.to run.with_params(id).and_return({})
      end

      it 'should return current password and empty history when only current password exists' do
        subject()
        settings = call_function('simplib::passgen::legacy::common_settings')
        FileUtils.mkdir_p(settings['keydir'])
        password_file = File.join(settings['keydir'], id)
        File.open(password_file, 'w') { |file| file.puts password }
        salt_file = File.join(settings['keydir'], "#{id}.salt")
        File.open(salt_file, 'w') { |file| file.puts salt }

        expected = {
          'value'    => { 'password' => password, 'salt' => salt },
          'metadata' => { 'history' => [] }
        }
        is_expected.to run.with_params(id).and_return(expected)
      end

      it 'should return current password and history when both current and last passwords exist' do
        subject()
        settings = call_function('simplib::passgen::legacy::common_settings')
        FileUtils.mkdir_p(settings['keydir'])
        password_file = File.join(settings['keydir'], id)
        File.open(password_file, 'w') { |file| file.puts password }
        salt_file = File.join(settings['keydir'], "#{id}.salt")
        File.open(salt_file, 'w') { |file| file.puts salt }

        last_password_file = File.join(settings['keydir'], "#{id}.last")
        File.open(last_password_file, 'w') { |file| file.puts history[0][0] }
        last_salt_file = File.join(settings['keydir'], "#{id}.salt.last")
        File.open(last_salt_file, 'w') { |file| file.puts history[0][1] }

        expected = {
          'value'    => { 'password' => password, 'salt' => salt },
          'metadata' => { 'history' => [ history[0] ] }
        }
        is_expected.to run.with_params(id).and_return(expected)
      end
    end

    context 'failures' do
      it 'fails when a password file cannot be read' do
        subject()
        settings = call_function('simplib::passgen::legacy::common_settings')
        FileUtils.mkdir_p(settings['keydir'])
        password_file = File.join(settings['keydir'], id)
        File.open(password_file, 'w') { |file| file.puts password }
        salt_file = File.join(settings['keydir'], "#{id}.salt")
        File.open(salt_file, 'w') { |file| file.puts salt }

        IO.expects(:readlines).with(password_file).
          raises(Errno::EACCES, 'read failed')
        is_expected.to run.with_params(id).and_raise_error(Errno::EACCES,
          'Permission denied - read failed')
      end

    end
  end

  context 'libkv passgen::get' do
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

    context 'successes' do
      it 'should return {} when the password does not exist' do
        is_expected.to run.with_params(id).and_return( {} )
      end

      it 'should return a stored password' do
        # call subject() to make sure test Puppet environment is created
        # before we try to pre-populate the default key/value store with
        # a password
        subject()
        value = { 'password' => password, 'salt' => salt }
        meta = {
          'complexity' => complexity,
          'complex_only' => complex_only,
          'history' => history
        }
        call_function('libkv::put', key, value, meta)

        expected = { 'value' => value, 'metadata' => meta}
        expect( subject.execute(id) ).to eq expected
      end
    end

    context 'failures' do
      it 'fails when returned info is incomplete' do
        subject()
        value = { 'salt' => salt }
        meta = {
          'complexity' => complexity,
          'complex_only' => complex_only,
          'history' => history
        }
        call_function('libkv::put', key, value, meta)

        is_expected.to run.with_params(id).and_raise_error(RuntimeError,
          /Malformed password info retrieved for 'my_id'/)
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

        is_expected.to run.with_params(id, libkv_options).
          and_raise_error(ArgumentError,
          /libkv Configuration Error/)
      end
    end
  end
end
