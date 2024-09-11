#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::legacy::get' do
  let(:id) { 'my_id' }
  let(:password) { 'password for my_id 1' }
  let(:salt) { 'salt for my_id 1' }
  let(:history) { [
    [ 'password for my_id 0', 'salt for my_id 0']
  ] }

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
        'metadata' => { 'history' => history }
      }
      is_expected.to run.with_params(id).and_return(expected)
    end

    it 'should disregard a current password that is empty even when current salt is not empty' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      password_file = File.join(settings['keydir'], id)
      File.open(password_file, 'w') { |file| file.puts '' }
      salt_file = File.join(settings['keydir'], "#{id}.salt")
      File.open(salt_file, 'w') { |file| file.puts salt }

      last_password_file = File.join(settings['keydir'], "#{id}.last")
      File.open(last_password_file, 'w') { |file| file.puts history[0][0] }
      last_salt_file = File.join(settings['keydir'], "#{id}.salt.last")
      File.open(last_salt_file, 'w') { |file| file.puts history[0][1] }

      is_expected.to run.with_params(id).and_return({})
    end

    it 'should disregard a previous password that is empty even when previous salt is not empty' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      password_file = File.join(settings['keydir'], id)
      File.open(password_file, 'w') { |file| file.puts password }
      salt_file = File.join(settings['keydir'], "#{id}.salt")
      File.open(salt_file, 'w') { |file| file.puts salt }

      last_password_file = File.join(settings['keydir'], "#{id}.last")
      File.open(last_password_file, 'w') { |file| file.puts '' }
      last_salt_file = File.join(settings['keydir'], "#{id}.salt.last")
      File.open(last_salt_file, 'w') { |file| file.puts history[0][1] }

      expected = {
        'value'    => { 'password' => password, 'salt' => salt },
        'metadata' => { 'history' => [] }
      }
      is_expected.to run.with_params(id).and_return(expected)
    end

    it 'should disregard a missing current password even when current salt is present' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      salt_file = File.join(settings['keydir'], "#{id}.salt")
      File.open(salt_file, 'w') { |file| file.puts salt }

      last_password_file = File.join(settings['keydir'], "#{id}.last")
      File.open(last_password_file, 'w') { |file| file.puts history[0][0] }
      last_salt_file = File.join(settings['keydir'], "#{id}.salt.last")
      File.open(last_salt_file, 'w') { |file| file.puts history[0][1] }

      is_expected.to run.with_params(id).and_return({})
    end

    it 'should disregard a missing previous password even when previous salt is present' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      password_file = File.join(settings['keydir'], id)
      File.open(password_file, 'w') { |file| file.puts password }
      salt_file = File.join(settings['keydir'], "#{id}.salt")
      File.open(salt_file, 'w') { |file| file.puts salt }

      last_salt_file = File.join(settings['keydir'], "#{id}.salt.last")
      File.open(last_salt_file, 'w') { |file| file.puts history[0][1] }

      expected = {
        'value'    => { 'password' => password, 'salt' => salt },
        'metadata' => { 'history' => [] }
      }
      is_expected.to run.with_params(id).and_return(expected)
    end
  end

  context 'error cases' do
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
