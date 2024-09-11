require 'spec_helper'

describe "simplib__sshd_config" do

  before :each do
    Facter.clear

    Facter::Util::Resolution.expects(:which).with('sshd').returns('/usr/bin/sshd')
    Facter::Core::Execution.expects(:execute).with('/usr/bin/sshd --help 2>&1', :on_fail => :failed).returns(openssh_version['full_version'])

    File.expects(:exist?).with('/etc/ssh/sshd_config').returns(true)
    File.expects(:readable?).with('/etc/ssh/sshd_config').returns(true)
    File.expects(:read).with('/etc/ssh/sshd_config').returns(sshd_config_content)

    # This resets the stubbing code in Mocha to ensure that the code does not
    # try to catch any other calls to the stubbed methods above.
    #
    # This is not documented well and is almost always what you want in
    # Puppet testing

    File.stubs(:exist?).with(Not(equals('/etc/ssh/sshd_config')))
    File.stubs(:readable?).with(Not(equals('/etc/ssh/sshd_config')))
    File.stubs(:read).with(Not(equals('/etc/ssh/sshd_config')))
  end

  let(:openssh_version) {{
    'full_version' => 'OpenSSH_7.9p1, OpenSSL 1.1.1a FIPS  20 Nov 2018',
    'version' => '7.9p1'
  }}

  context 'with a simp /etc/ssh/sshd_config' do
    let(:sshd_config_content) { <<-EOM
#Brief chunk of file
Port 22
ListenAddress 0.0.0.0
#ListenAddress ::

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile      /etc/ssh/local_keys/%u

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
#AuthorizedKeysCommandUser nobody
AuthorizedKeysCommandUser nobody

# Even inline comments!
    # And indented comments
      EOM
    }
    it {
      expect(Facter.fact('simplib__sshd_config').value).to eq(openssh_version.merge({"AuthorizedKeysFile"=>"/etc/ssh/local_keys/%u"}))
    }
  end

  context 'with a default /etc/ssh/sshd_config' do
    let(:sshd_config_content) { <<-EOM
#Brief chunk of file
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile      .ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# Even inline comments!
    # And indented comments
      EOM
    }

    it {
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' }))
    }

    context 'when the SSH daemon does not return a version string' do
      let(:openssh_version) {{
        'full_version' => :failed,
        'version' => nil
      }}

      it {
        expect(Facter.fact(:simplib__sshd_config).value).to eq({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' })
      }
    end

    context 'when the SSH daemon does not return a valid version string' do
      let(:openssh_version) {{
        'full_version' => 'OpenSSH_is amazing',
        'version' => nil
      }}

      it {
        expect(Facter.fact(:simplib__sshd_config).value).to eq({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' })
      }
    end
  end

  context 'with a commented values /etc/ssh/sshd_config' do
    let(:sshd_config_content) { <<-EOM
#Brief chunk of file
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
#AuthorizedKeysFile       /etc/ssh/local_keys/%u

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody
      EOM
    }

    it {
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' }))
    }
  end

  context 'with empty /etc/ssh/sshd_config' do
    let(:sshd_config_content) {''}

    it {
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge({ 'AuthorizedKeysFile' => '.ssh/authorized_keys' }))
    }
  end

  context 'with multiple matching entries' do
    let(:sshd_config_content) { <<-EOM
#Brief chunk of file
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile       /etc/ssh/local_keys/%u
AuthorizedKeysFile       /foo/bar/baz

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody
      EOM
    }

    it {
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge(
        { 'AuthorizedKeysFile' => ['/etc/ssh/local_keys/%u', '/foo/bar/baz'] }
      ))
    }
  end

  context 'with multiple entries in a Match block' do
    let(:sshd_config_content) { <<-EOM
#Brief chunk of file
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
Match user foo
  AuthorizedKeysFile       /etc/ssh/local_keys/%u
  AuthorizedKeysFile       /foo/bar/baz

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody
      EOM
    }

    it {
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge(
        {
          'AuthorizedKeysFile' => '.ssh/authorized_keys',
          'Match user foo' => {
            'AuthorizedKeysFile' => [ '/etc/ssh/local_keys/%u', '/foo/bar/baz']
          }
        }
      ))
    }
  end

  context 'with global and Match block entries' do
    let(:sshd_config_content) { <<-EOM
#Brief chunk of file
#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#PubkeyAuthentication yes

AuthorizedKeysFile       /global/time

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
Match user foo
  AuthorizedKeysFile       /etc/ssh/local_keys/%u
  AuthorizedKeysFile       /foo/bar/baz

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody
      EOM
    }

    it {
      expect(Facter.fact(:simplib__sshd_config).value).to eq(openssh_version.merge(
        {
          'AuthorizedKeysFile' => '/global/time',
          'Match user foo' => {
            'AuthorizedKeysFile' => [ '/etc/ssh/local_keys/%u', '/foo/bar/baz']
          }
        }
      ))
    }
  end
end
