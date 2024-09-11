require 'spec_helper'

describe "redact" do
  let(:node) { 'test.example.com' }
  let(:facts) { {
    :fqdn     => 'test.example.com',
  } }
  let(:params) { {
    :param    => 'a param',
    :redacted => 'to be redacted',
    :replaced => 'to be replaced',
  } }

  it { is_expected.to contain_class('redact').with({
      :param    => 'a param',
      :redacted => '<<redacted>>',
      :replaced => 'a replacement string',
    })
  }
  it { is_expected.to contain_redact__thing('one').with({
      :param    => 'a param',
      :redacted => '<<redacted>>',
      :replaced => 'a replacement string',
    })
  }
  it { is_expected.to contain_redact__thing('two').with({
      :param    => 'a param',
      :redacted => '<<redacted>>',
      :replaced => 'a replacement string',
    })
  }

end
