require 'spec_helper'

describe 'Simplib::Domain' do
  # Tests cover RFC 3696, Section 2
  # RegEx + test cases developed at http://rubular.com/r/4yZ7R8v42f

  context 'with valid DNS domain names' do
    context 'Only ASCII alpha + numbers + hyphens are allowed' do
      it { is_expected.to allow_value('test.com') }
      it { is_expected.to allow_value('test') }
      it { is_expected.to allow_value('t') }
      it { is_expected.to allow_value('0.t-t.0.t') }
      it { is_expected.to allow_value('0-0') }
      it { is_expected.to allow_value('0-0.0-0.0-0') }
      it { is_expected.to allow_value('0f') }
      it { is_expected.to allow_value('f0') }
      it { is_expected.to allow_value('test.00f') }
    end

    context 'TLDs may end with a trailing period' do
      it { is_expected.to allow_value('t.') }
      it { is_expected.to allow_value('test.com.') }
    end
  end

  context 'with invalid DNS domain names' do
    context "labels can't begin or end with hyphens" do
      it { is_expected.not_to allow_value('-test') }
      it { is_expected.not_to allow_value('test-') }
      it { is_expected.not_to allow_value('test-.test') }
      it { is_expected.not_to allow_value('test.-test') }
    end

    context 'TLDs cannot be all-numeric' do
      it { is_expected.not_to allow_value('0') }
      it { is_expected.not_to allow_value('0212') }
      it { is_expected.not_to allow_value('test.0') }
      it { is_expected.not_to allow_value('t.t.t.t.0') }
    end

    context 'A DNS label may be no more than 63 octets long' do
      it { is_expected.not_to allow_value('an-extremely-long-dns-label-that-is-just-over-63-characters-long.test') }
      it { is_expected.not_to allow_value('test.an-extremely-long-dns-label-that-is-just-over-63-characters-long') }
      it { is_expected.not_to allow_value('test.an-extremely-long-dns-label-that-is-just-over-63-characters-long.test') }
      it { is_expected.not_to allow_value('an-extremely-long-dns-label-that-is-just-over-63-characters-long.') }
    end
  end

  context 'with silly things' do
    it { is_expected.not_to allow_value([]) }
    it { is_expected.not_to allow_value('.') }
    it { is_expected.not_to allow_value('' ) }
    it { is_expected.not_to allow_value("test.c m") }
    it { is_expected.not_to allow_value("test.com\n") }
    it { is_expected.not_to allow_value(:undef) }
  end
end
