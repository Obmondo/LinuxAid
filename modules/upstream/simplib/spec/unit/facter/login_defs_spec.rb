require 'spec_helper'

describe "custom fact login_defs" do

  before(:each) do
    Facter.clear

    Facter.stubs(:value).with(:operatingsystem).returns('Linux')
  end

  context 'with a well formed /etc/login.defs' do
    let(:login_defs_content) { <<-EOM
# I can haz comments!
MAIL_DIR        /var/spool/mail

PASS_MAX_DAYS   99999
PASS_MIN_DAYS   0

PASS_MIN_LEN    5

PASS_WARN_AGE   7

UID_MIN         1000
UID_MAX         60000

SYS_UID_MIN     201
SYS_UID_MAX     999

GID_MIN         1000
GID_MAX         60000

SYS_GID_MIN     201
SYS_GID_MAX     999

CREATE_HOME     yes

UMASK           077
USERGROUPS_ENAB yes
    
# Even inline comments!
    # And indented comments
ENCRYPT_METHOD  SHA512
MD5_CRYPT_ENAB  no
      EOM
    }

    it 'should return hash of values from /etc/login.defs with appropriate conversions' do
      File.expects(:exist?).with('/etc/login.defs').returns(true)
      File.expects(:readable?).with('/etc/login.defs').returns(true)
      File.expects(:read).with('/etc/login.defs').returns(login_defs_content)

      # This resets the stubbing code in Mocha to ensure that the code does not
      # try to catch any other calls to the stubbed methods above.
      #
      # This is not documented well and is almost always what you want in
      # Puppet testing
      File.stubs(:exist?).with(Not(equals('/etc/login.defs')))
      File.stubs(:readable?).with(Not(equals('/etc/login.defs')))
      File.stubs(:read).with(Not(equals('/etc/login.defs')))

      expect(Facter.fact('login_defs').value).to eq({
        "mail_dir"        =>"/var/spool/mail",
        "pass_max_days"   =>99999,
        "pass_min_days"   =>0,
        "pass_min_len"    =>5,
        "pass_warn_age"   =>7,
        "uid_min"         =>1000,
        "uid_max"         =>60000,
        "sys_uid_min"     =>201,
        "sys_uid_max"     =>999,
        "gid_min"         =>1000,
        "gid_max"         =>60000,
        "sys_gid_min"     =>201,
        "sys_gid_max"     =>999,
        "create_home"     =>true,
        "umask"           =>"077",
        "usergroups_enab" =>true,
        "encrypt_method"  =>"SHA512",
        "md5_crypt_enab"  =>false
      })
    end
  end

  context 'with an empty login.defs' do
    it 'should return hash of the uid_min and gid_min defaults' do
      File.expects(:exist?).with('/etc/login.defs').returns(true)
      File.expects(:readable?).with('/etc/login.defs').returns(true)
      File.expects(:read).with('/etc/login.defs').returns('')

      File.stubs(:exist?).with(Not(equals('/etc/login.defs')))
      File.stubs(:readable?).with(Not(equals('/etc/login.defs')))
      File.stubs(:read).with(Not(equals('/etc/login.defs')))

      expect(Facter.fact('login_defs').value).to eq({ })
    end
  end
end
