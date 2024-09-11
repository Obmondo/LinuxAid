#!/usr/bin/env ruby -S rspec
require 'spec_helper'

describe 'simplib::passgen::gen_password_and_salt' do

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

  context 'successes' do

    it 'should return appropriate salt and a password that contains default characters if complexity is 0' do
      password,salt = subject.execute(48, 0, false, 30)

      expect(salt.length).to eql(16)
      expect(salt).to match(/^(#{default_chars.join('|')})+$/)
      expect(salt).not_to match(/(#{(safe_special_chars).join('|')})/)
      expect(salt).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      expect(password.length).to eql(48)
      expect(password).to match(/^(#{default_chars.join('|')})+$/)
      expect(password).not_to match(/(#{(safe_special_chars).join('|')})/)
      expect(password).not_to match(/(#{(unsafe_special_chars).join('|')})/)
    end

    it 'should return appropriate salt and a password that contains "safe" special characters if complexity is 1' do
      password,salt = subject.execute(128, 1, false, 30)

      expect(salt.length).to eql(16)
      expect(salt).to match(/^(#{default_chars.join('|')})+$/)
      expect(salt).not_to match(/(#{(safe_special_chars).join('|')})/)
      expect(salt).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      expect(password.length).to eql(128)
      expect(password).to match(/(#{default_chars.join('|')})/)
      expect(password).to match(/(#{(safe_special_chars).join('|')})/)
      expect(password).not_to match(/(#{(unsafe_special_chars).join('|')})/)
    end

    it 'should return appropriate salt and a password that only contains "safe" special characters if complexity is 1 and complex_only is true' do
      password,salt = subject.execute(128, 1, true, 30)

      expect(salt.length).to eql(16)
      expect(salt).to match(/^(#{default_chars.join('|')})+$/)
      expect(salt).not_to match(/(#{(safe_special_chars).join('|')})/)
      expect(salt).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      expect(password.length).to eql(128)
      expect(password).not_to match(/(#{default_chars.join('|')})/)
      expect(password).to match(/(#{(safe_special_chars).join('|')})/)
      expect(password).not_to match(/(#{(unsafe_special_chars).join('|')})/)
    end

    it 'should return appropriate salt and a password that contains all special characters if complexity is 2' do
      password,salt = subject.execute(128, 2, false, 30)

      expect(salt.length).to eql(16)
      expect(salt).to match(/^(#{default_chars.join('|')})+$/)
      expect(salt).not_to match(/(#{(safe_special_chars).join('|')})/)
      expect(salt).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      expect(password.length).to eql(128)
      expect(password).to match(/(#{default_chars.join('|')})/)
      expect(password).to match(/(#{(safe_special_chars).join('|')})/)
      expect(password).to match(/(#{(unsafe_special_chars).join('|')})/)
    end

    it 'should return appropriate salt and a password that only contains all special characters if complexity is 2 and complex_only is true' do
      password,salt = subject.execute(128, 2, true, 30)

      expect(salt.length).to eql(16)
      expect(salt).to match(/^(#{default_chars.join('|')})+$/)
      expect(salt).not_to match(/(#{(safe_special_chars).join('|')})/)
      expect(salt).not_to match(/(#{(unsafe_special_chars).join('|')})/)

      expect(password.length).to eql(128)
      expect(password).to_not match(/(#{default_chars.join('|')})/)
      expect(password).to match match(/(#{(safe_special_chars).join('|')})/)
      expect(password).to match(/(#{(unsafe_special_chars).join('|')})/)
    end
  end

  context 'errors' do
    it 'fails when password generation times out' do
      Timeout.expects(:timeout).with(30).raises(Timeout::Error, 'Timeout')
      is_expected.to run.with_params(16, 0, false, 30).and_raise_error(Timeout::Error,
        'Timeout')
    end
  end
end
