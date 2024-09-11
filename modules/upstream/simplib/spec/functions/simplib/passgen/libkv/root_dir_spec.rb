#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::libkv::root_dir' do
  it "should return passgen's root directory in libkv" do
    is_expected.to run.and_return('gen_passwd')
  end
end
