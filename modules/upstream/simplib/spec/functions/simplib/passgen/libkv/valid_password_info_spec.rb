#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::libkv::valid_password_info' do
  let(:password) { 'password for my_id 2' }
  let(:salt) { 'salt for my_id 2' }
  let(:complexity) { 0 }
  let(:complex_only) { false }
  let(:history) { [
    [ 'password for my_id 1', 'salt for my_id 1'],
    [ 'password for my_id 0', 'salt for my_id 0']
  ] }

  it 'should return true when password info is complete' do
    password_info = {
      'value'    => { 'password' => password, 'salt' => salt },
      'metadata' => {
        'complexity'   => complexity,
        'complex_only' => complex_only,
        'history'      => history
      }
    }

    is_expected.to run.with_params(password_info).and_return(true)
  end

  it 'fails when returned info is missing password key' do
    password_info = {
      'value'    => { 'salt' => salt },
      'metadata' => {
      'complexity' => complexity,
      'complex_only' => complex_only,
      'history' => history
      }
    }

    is_expected.to run.with_params(password_info).and_return(false)
  end

  it 'fails when returned info is missing salt key' do
    password_info = {
      'value'    => { 'password' => password },
      'metadata' => {
      'complexity' => complexity,
      'complex_only' => complex_only,
      'history' => history
      }
    }

    is_expected.to run.with_params(password_info).and_return(false)
  end

  it 'fails when returned info is missing metadata key' do
    password_info = {
      'value'    => { 'password' => password, 'salt' => salt }
    }

    is_expected.to run.with_params(password_info).and_return(false)
  end

  it 'fails when returned info is missing complexity key' do
    password_info = {
      'value'    => { 'password' => password, 'salt' => salt },
      'metadata' => {
      'complex_only' => complex_only,
      'history' => history
      }
    }

    is_expected.to run.with_params(password_info).and_return(false)
  end

  it 'fails when returned info is missing complex_only key' do
    password_info = {
      'value'    => { 'password' => password, 'salt' => salt },
      'metadata' => {
      'complexity' => complexity,
      'history' => history
      }
    }

    is_expected.to run.with_params(password_info).and_return(false)
  end

  it 'fails when returned info is missing history key' do
    password_info = {
      'value'    => { 'password' => password, 'salt' => salt },
      'metadata' => {
      'complexity' => complexity,
      'complex_only' => complex_only
      }
    }

    is_expected.to run.with_params(password_info).and_return(false)
  end
end
