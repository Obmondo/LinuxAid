#!/usr/bin/env ruby -S rspec
require 'spec_helper'

def store_valid_passwords(folder, id_base, password_base, salt_base, recurse = true)

  expected = { 'keys' => {}, 'folders' => [] }

  # add keys in the folder
  (1..3).each do |num|
    id = "#{id_base}_#{num}"
    full_id = folder.empty? ? id : "#{folder}/#{id}"
    prev_password    = "old #{password_base} #{num}"
    current_password = "#{password_base} #{num}"
    prev_salt        = "old #{salt_base} #{num}"
    current_salt     = "#{salt_base} #{num}"
    complexity       = 2
    complex_only     = true

    call_function('simplib::passgen::libkv::set', full_id, prev_password,
      prev_salt, complexity, complex_only)

    call_function('simplib::passgen::libkv::set', full_id, current_password,
      current_salt, complexity, complex_only)

    key = "#{folder}/#{id}"
    value = { 'password' => current_password, 'salt' => current_salt }
    meta = {
      'complexity'   => complexity,
      'complex_only' => complex_only,
      'history' => [ [ prev_password, prev_salt ] ]
    }

    expected['keys'][id] = { 'value' => value, 'metadata' => meta }
  end


  if recurse
    # add keys in a sub-folders
    (1..2).each do |num|
      subfolder = "sub#{num}"
      full_subfolder =  folder.empty? ? subfolder : "#{folder}/#{subfolder}"
      store_valid_passwords(full_subfolder, id_base, password_base, salt_base, false)

      expected['folders'] << subfolder
    end
  end

  expected
end

describe 'simplib::passgen::libkv::list' do
  let(:key_root_dir) { 'gen_passwd' }
  let(:id_base) { 'my_id' }
  let(:password_base) { 'password for my_id' }
  let(:salt_base) { 'salt for my_id' }
  let(:sub_folder) { 'my/sub/folder' }

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
    context 'root folder' do
      it 'should return {} when the root folder does not exist' do
        is_expected.to run.with_params().and_return( {} )

      end

      it 'should return empty password and folder results when the root folder is empty' do
        # call subject() to make sure test Puppet environment is created
        # before we try to pre-populate the default key/value store with
        # passwords
        subject()
        call_function('simplib::passgen::libkv::set', 'my_id', 'password',
          'salt', 1, true)
        call_function('simplib::passgen::libkv::remove', 'my_id')

        expected = { 'keys' => {}, 'folders' => [] }
        is_expected.to run.with_params().and_return( expected )
      end

      it 'should return password info and folders when root folder is not empty' do
        subject()
        expected = store_valid_passwords('', id_base, password_base, salt_base)

        is_expected.to run.with_params().and_return( expected )
      end

      it 'should skip bad entries' do
        subject()
        # store valid passwords
        expected = store_valid_passwords('', id_base, password_base, salt_base)

        # store an invalid password entry (missing metadata)
        key_without_meta = "#{key_root_dir}/bad_key"
        value = {
          'password' => "bad_key #{password_base}",
          'salt' => "bad_key #{salt_base}"
        }
        call_function('libkv::put', key_without_meta, value)

        is_expected.to run.with_params().and_return( expected )
      end
    end

    context 'sub-folder' do
      it 'should return {} when the sub-folder does not exist' do
        is_expected.to run.with_params(sub_folder).and_return( {} )
      end

      it 'should return empty password and folder results when the sub-folder is empty' do
        # call subject() to make sure test Puppet environment is created
        # before we try to pre-populate the default key/value store with
        # passwords
        subject()
        call_function('simplib::passgen::libkv::set', "#{sub_folder}/my_id",
          'password', 'salt', 1, true)
        call_function('simplib::passgen::libkv::remove', "#{sub_folder}/my_id")

        expected = { 'keys' => {}, 'folders' => [] }
        is_expected.to run.with_params(sub_folder).and_return( expected )
      end

      it 'should return password info and folders when sub-folder is not empty' do
        subject()
        expected = store_valid_passwords(sub_folder,
          id_base, password_base, salt_base)

        is_expected.to run.with_params(sub_folder).and_return( expected )
      end

      it 'should skip bad entries' do
        subject()
        # store valid passwords
        expected = store_valid_passwords(sub_folder,
          id_base, password_base, salt_base)

        # store an invalid password entry (missing metadata)
        key_without_meta = "#{key_root_dir}/#{sub_folder}/bad_key"
        value = {
          'password' => "bad_key #{password_base}",
          'salt' => "bad_key #{salt_base}"
        }
        call_function('libkv::put', key_without_meta, value)

        is_expected.to run.with_params(sub_folder).and_return( expected )
      end
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

      is_expected.to run.with_params('/', libkv_options).
        and_raise_error(ArgumentError,
        /libkv Configuration Error/)
    end
  end
end
