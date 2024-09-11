#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::gen_salt' do

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


  it 'should return salt with length 16 and complexity of 0 when default timeout_seconds is used' do
    salt = subject.execute()

    expect(salt.length).to eql(16)
    expect(salt).to match(/^(#{default_chars.join('|')})+$/)
    expect(salt).not_to match(/(#{(safe_special_chars).join('|')})/)
    expect(salt).not_to match(/(#{(unsafe_special_chars).join('|')})/)
  end

  it 'should return salt with length 16 and complexity of 0 when timeout_seconds is specified' do
    salt = subject.execute(15)

    expect(salt.length).to eql(16)
    expect(salt).to match(/^(#{default_chars.join('|')})+$/)
    expect(salt).not_to match(/(#{(safe_special_chars).join('|')})/)
    expect(salt).not_to match(/(#{(unsafe_special_chars).join('|')})/)
  end

  it 'fails when salt generation times out' do
    Timeout.expects(:timeout).with(20).raises(Timeout::Error, 'Timeout')
    is_expected.to run.with_params(20).and_raise_error(Timeout::Error,
      'Timeout')
  end
end
