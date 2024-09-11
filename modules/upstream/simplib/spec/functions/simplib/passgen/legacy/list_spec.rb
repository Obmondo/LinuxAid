#!/usr/bin/env ruby -S rspec
require 'spec_helper'

def store_valid_legacy_passwords(id_base, password_base, salt_base)

  expected = { 'keys' => {}, 'folders' => [] }

  # add passwords
  (1..3).each do |num|
    id = "#{id_base}_#{num}"
    prev_password    = "old #{password_base} #{num}"
    current_password = "#{password_base} #{num}"
    prev_salt        = "old #{salt_base} #{num}"
    current_salt     = "#{salt_base} #{num}"

    call_function('simplib::passgen::legacy::set', id, prev_password, prev_salt)
    call_function('simplib::passgen::legacy::set', id, current_password, current_salt)

    value = { 'password' => current_password, 'salt' => current_salt }
    meta = { 'history' => [ [ prev_password, prev_salt ] ] }
    expected['keys'][id] = { 'value' => value, 'metadata' => meta }
  end

  expected
end

describe 'simplib::passgen::legacy::list' do
  let(:id_base) { 'my_id' }
  let(:password_base) { 'password for my_id' }
  let(:salt_base) { 'salt for my_id' }

  context 'successes' do
    it 'should return {} when the root folder does not exist' do
      is_expected.to run.with_params().and_return( {} )
    end

    it 'should return empty password and folder results when the root folder is empty' do
      # call subject() to make sure test Puppet environment is created
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])

      expected = { 'keys' => {}, 'folders' => [] }
      is_expected.to run.with_params().and_return( expected )
    end

    it 'should return password info and folders when root folder is not empty' do
      subject()
      expected = store_valid_legacy_passwords(id_base, password_base, salt_base)

      is_expected.to run.with_params().and_return( expected )
    end

    it 'should skip bad entries' do
      subject()
      # store valid passwords
      expected = store_valid_legacy_passwords(id_base, password_base, salt_base)

      # store an invalid password entry (empty content)
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      FileUtils.touch(File.join(settings['keydir'], 'bad_key'))

      is_expected.to run.with_params().and_return( expected )
    end
  end

  context 'failures' do
    it 'fails when the password root directory cannot be accessed' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      Dir.expects(:chdir).with(settings['keydir']).
        raises(Errno::EACCES, 'chdir failed')

      is_expected.to run.with_params().and_raise_error(Errno::EACCES,
        'Permission denied - chdir failed')
    end
  end
end
