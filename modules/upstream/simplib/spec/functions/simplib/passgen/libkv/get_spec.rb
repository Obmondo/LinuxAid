#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::libkv::get' do
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
        'complexity'   => complexity,
        'complex_only' => complex_only,
        'history'      => history
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
        'complexity'   => complexity,
        'complex_only' => complex_only,
        'history'      => history
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
