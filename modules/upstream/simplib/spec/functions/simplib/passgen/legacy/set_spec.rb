#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::legacy::set' do
  let(:id) { 'my_id' }
  let(:passwords) { [
    'password for my_id 3',
    'password for my_id 2',
    'password for my_id 1',
    'password for my_id 0'
  ] }

  let(:salts) { [
    'salt for my_id 3',
    'salt for my_id 2',
    'salt for my_id 1',
    'salt for my_id 0'
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
    it 'should create password and salt files when password does not exist' do
      is_expected.to run.with_params(id, passwords[0], salts[0])

      settings = call_function('simplib::passgen::legacy::common_settings')
      password_file = File.join(settings['keydir'], id)
      salt_file = File.join(settings['keydir'], "#{id}.salt")
      expect( Dir.exist?(settings['keydir']) ).to be true
      expect( File.exist?(password_file) ).to be true
      expect( IO.read(password_file).chomp ).to eq passwords[0]
      expect( File.stat(password_file).mode & 0777 ).to eq(settings['file_mode'])
      expect( File.exist?(salt_file) ).to be true
      expect( IO.read(salt_file).chomp ).to eq salts[0]
      expect( File.stat(salt_file).mode & 0777 ).to eq(settings['file_mode'])

      expect( File.exist?("#{password_file}.last") ).to be false
      expect( File.exist?("#{salt_file}.last") ).to be false
      expect( File.exist?("#{password_file}.last.last") ).to be false
      expect( File.exist?("#{salt_file}.last.last") ).to be false
    end

    it 'should backup existing password and salt files and create current ones' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      password_file = File.join(settings['keydir'], id)
      File.open(password_file, 'w') { |file| file.puts passwords[1] }
      salt_file = File.join(settings['keydir'], "#{id}.salt")
      File.open(salt_file, 'w') { |file| file.puts salts[1] }

      is_expected.to run.with_params(id, passwords[0], salts[0])

      expect( IO.read(password_file).chomp ).to eq passwords[0]
      expect( IO.read(salt_file).chomp ).to eq salts[0]

      password_file_last = "#{password_file}.last"
      salt_file_last = "#{salt_file}.last"
      expect( IO.read(password_file_last).chomp ).to eq passwords[1]
      expect( IO.read(salt_file_last).chomp ).to eq salts[1]
    end

    it 'should backup existing backup files' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      password_file = File.join(settings['keydir'], id)
      password_file_last = "#{password_file}.last"
      password_file_last_last = "#{password_file}.last.last"
      File.open(password_file, 'w') { |file| file.puts passwords[1] }
      File.open(password_file_last, 'w') { |file| file.puts passwords[2] }
      File.open(password_file_last_last, 'w') { |file| file.puts passwords[3] }

      salt_file = File.join(settings['keydir'], "#{id}.salt")
      salt_file_last = "#{salt_file}.last"
      salt_file_last_last = "#{salt_file}.last.last"
      File.open(salt_file, 'w') { |file| file.puts salts[1] }
      File.open(salt_file_last, 'w') { |file| file.puts salts[2] }
      File.open(salt_file_last_last, 'w') { |file| file.puts salts[3] }

      is_expected.to run.with_params(id, passwords[0], salts[0])

      expect( IO.read(password_file).chomp ).to eq passwords[0]
      expect( IO.read(salt_file).chomp ).to eq salts[0]
      expect( IO.read(password_file_last).chomp ).to eq passwords[1]
      expect( IO.read(salt_file_last).chomp ).to eq salts[1]
      expect( IO.read(password_file_last_last).chomp ).to eq passwords[2]
      expect( IO.read(salt_file_last_last).chomp ).to eq salts[2]
    end

    it 'should remove backup salt if existing salt missing' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      password_file = File.join(settings['keydir'], id)
      password_file_last = "#{password_file}.last"
      File.open(password_file, 'w') { |file| file.puts passwords[1] }
      File.open(password_file_last, 'w') { |file| file.puts passwords[2] }

      salt_file = File.join(settings['keydir'], "#{id}.salt")
      salt_file_last = "#{salt_file}.last"
      File.open(salt_file_last, 'w') { |file| file.puts salts[2] }

      is_expected.to run.with_params(id, passwords[0], salts[0])

      expect( File.exist?(password_file) ).to be true
      expect( File.exist?(password_file_last) ).to be true
      expect( File.exist?(salt_file) ).to be true
      expect( File.exist?(salt_file_last) ).to be false
    end

    it 'should remove backup of backup files if backup files missing' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.mkdir_p(settings['keydir'])
      password_file = File.join(settings['keydir'], id)
      password_file_last = "#{password_file}.last"
      password_file_last_last = "#{password_file}.last.last"
      File.open(password_file, 'w') { |file| file.puts passwords[1] }
      File.open(password_file_last_last, 'w') { |file| file.puts passwords[3] }

      salt_file = File.join(settings['keydir'], "#{id}.salt")
      salt_file_last = "#{salt_file}.last"
      salt_file_last_last = "#{salt_file}.last.last"
      File.open(salt_file, 'w') { |file| file.puts salts[1] }
      File.open(salt_file_last_last, 'w') { |file| file.puts salts[3] }

      is_expected.to run.with_params(id, passwords[0], salts[0])

      expect( File.exist?(password_file) ).to be true
      expect( File.exist?(password_file_last) ).to be true
      expect( File.exist?(password_file_last_last) ).to be false
      expect( File.exist?(salt_file) ).to be true
      expect( File.exist?(salt_file_last) ).to be true
      expect( File.exist?(salt_file_last_last) ).to be false
    end
  end

  context 'error cases' do
    it 'fails when the key directory cannot be created' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      FileUtils.stubs(:mkdir_p).with(
          settings['keydir'], {:mode => settings['dir_mode']}
        ).raises(Errno::EACCES, 'dir create failed')

      is_expected.to run.with_params(id, passwords[0], salts[0]).
        and_raise_error(RuntimeError, /Could not make directory/)
    end

    it 'fails when a password/salt file cannot be created' do
      subject()
      settings = call_function('simplib::passgen::legacy::common_settings')
      password_file = File.join(settings['keydir'], id)
      # mocha doesn't allow us to tell it to call original implementation
      # in some cases (which rspec-mocks does).  So, have to mock a different
      # method in simplib::psssgen::legacy::set::write_file
#          File.stubs(:open).with(password_file, 'w').
#            raises(Errno::EACCES, 'file create failed')
      File.stubs(:chmod).with(settings['file_mode'], password_file).
        raises(Errno::EACCES, 'file chmod failed')
      File.stubs(:chmod).with(
        Not(equals(settings['file_mode'])), Not(equals(password_file)))

      is_expected.to run.with_params(id, passwords[0], salts[0]).
        and_raise_error( Errno::EACCES, 'Permission denied - file chmod failed')
    end
  end
end
