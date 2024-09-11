require 'spec_helper'

describe 'gerrit::config::git_config', :type => :define do
  let(:title) { 'test_git_config' }

  let(:params) {
    {
      'config_file'     => '/opt/test.config',
      'options'         => {
        'testsection'   => {
          'testvar1'    => 'testvar1',
          'testvar2'    => [ 'testvar2.1', 'testvar2.2' ],
        },
        'testsection.sub' => {
          'testvar3'    => 'testvar3',
        }
      },
      'mode'            => '0440',
    }
  }

  it 'should report an error when config_file not an absolute path' do
    params.merge!({'config_file' => 'invalid_val'})
    expect { subject }.to raise_error(Puppet::Error,
                                      /"invalid_val" is not an absolute path\./)
  end

  it 'should report an error when options is not a hash' do
    params.merge!({'options' => 'invalid_val'})
    expect { subject }.to raise_error(Puppet::Error,
                                      /"invalid_val" is not a Hash\./)
  end

  it 'should report an error when mode is not a valid file mode' do
    params.merge!({'mode' => 'invalid_val'})
    expect { subject }.to raise_error(Puppet::Error,
                                      /"invalid_val" is not supported for mode\. Allowed values are proper file modes\./)
  end

  context 'config file' do
    it { is_expected.to contain_file('/opt/test.config').with(
      'mode'    => '0440',
      'content' => "; MANAGED BY PUPPET\n\n[testsection]\n\ttestvar1 = testvar1\n\ttestvar2 = testvar2.1\n\ttestvar2 = testvar2.2\n\n[testsection \"sub\"]\n\ttestvar3 = testvar3\n\n",
    ) }
  end

end

# vim: sw=2 ts=2 sts=2 et :
