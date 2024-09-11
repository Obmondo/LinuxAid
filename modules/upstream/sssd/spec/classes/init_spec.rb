require 'spec_helper'
describe 'sssd' do
  platforms = {
    'amazon_linux2' => {
      :extra_packages => [
        'authconfig',
        'oddjob-mkhomedir',
      ],
      :manage_oddjobd => true,
      :facts_hash => {
        :osfamily => 'RedHat',
        :operatingsystem => 'Amazon',
        :operatingsystemmajrelease => '2',
        :os => {
          'family' => 'RedHat',
          'name'   => 'Amazon',
          'release' => {
            'major' => '2',
          },
        },
      },
    },
    'debian8' => {
      :extra_packages => [
        'libpam-runtime',
        'libpam-sss',
        'libnss-sss',
      ],
      :manage_oddjobd => false,
      :facts_hash => {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '8.1',
        :operatingsystemmajrelease => '8',
        :os => {
          'family' => 'Debian',
          'release' => {
            'major' => '8',
          },
        },
      },
    },
    'debian9' => {
      :extra_packages => [
        'libpam-runtime',
        'libpam-sss',
        'libnss-sss',
      ],
      :manage_oddjobd => false,
      :facts_hash => {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '9.0',
        :operatingsystemmajrelease => '9',
        :os => {
          'family' => 'Debian',
          'release' => {
            'major' => '9',
          },
        },
      },
    },
    'el6' => {
      :extra_packages => [
        'authconfig',
        'oddjob-mkhomedir',
      ],
      :service_dependencies => ['messagebus'],
      :manage_oddjobd => true,
      :facts_hash => {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemmajrelease => '6',
        :os => {
          'family' => 'RedHat',
          'name'   => 'RedHat',
          'release' => {
            'major' => '6',
          },
        },
      },
    },
    'el7' => {
      :extra_packages => [
        'authconfig',
        'oddjob-mkhomedir',
      ],
      :manage_oddjobd => true,
      :facts_hash => {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemmajrelease => '7',
        :os => {
          'family' => 'RedHat',
          'name'   => 'RedHat',
          'release' => {
            'major' => '7',
          },
        },
      },
    },
    'el8' => {
      :extra_packages => [
        'authselect',
        'oddjob-mkhomedir',
      ],
      :manage_oddjobd => true,
      :facts_hash => {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemmajrelease => '8',
        :os => {
          'family' => 'RedHat',
          'name'   => 'RedHat',
          'release' => {
            'major' => '8',
          },
        },
      },
    },
    'Fedora 29' => {
      :extra_packages => [
        'authselect',
        'oddjob-mkhomedir',
      ],
      :manage_oddjobd => true,
      :facts_hash => {
        :osfamily => 'RedHat',
        :operatingsystem => 'Fedora',
        :operatingsystemmajrelease => '29',
        :os => {
          'family' => 'RedHat',
          'name'   => 'Fedora',
          'release' => {
            'major' => '29',
          },
        },
      },
    },
    'Fedora 30' => {
      :extra_packages => [
        'authselect',
        'oddjob-mkhomedir',
      ],
      :manage_oddjobd => true,
      :facts_hash => {
        :osfamily => 'RedHat',
        :operatingsystem => 'Fedora',
        :operatingsystemmajrelease => '30',
        :os => {
          'family' => 'RedHat',
          'name'   => 'Fedora',
          'release' => {
            'major' => '30',
          },
        },
      },
    },
    'gentoo4' => {
      :manage_oddjobd => false,
      :facts_hash => {
        :osfamily => 'Gentoo',
        :operatingsystem => 'Gentoo',
        :operatingsystemrelease => '4.14.4-gentoo',
        :operatingsystemmajrelease => '4',
        :os => {
          'family' => 'Gentoo',
          'release' => {
            'major' => '4',
            'minor' => '14',
          },
        },
      },
    },
    'suse11_3_i386' => {
      :extra_packages => [
        'sssd-tools',
      ],
      :facts_hash => {
        :osfamily => 'Suse',
        :operatingsystem => 'SLES',
        :operatingsystemrelease => '11.3',
        :operatingsystemmajrelease => '11',
        :os => {
          'family'       => 'Suse',
          'architecture' => 'i386',
          'release' => {
            'major' => '11',
            'minor' => '3',
          },
        },
      },
    },
    'suse11_4_i386' => {
      :extra_packages => [
        'sssd-tools',
      ],
      :facts_hash => {
        :osfamily => 'Suse',
        :operatingsystem => 'SLES',
        :operatingsystemrelease => '11.4',
        :operatingsystemmajrelease => '11',
        :os => {
          'family'       => 'Suse',
          'architecture' => 'i386',
          'release' => {
            'major' => '11',
            'minor' => '4',
          },
        },
      },
    },
    'suse12_i386' => {
      :extra_packages => [
        'sssd-krb5',
        'sssd-ad',
        'sssd-ipa',
        'sssd-tools',
        'sssd-ldap',
      ],
      :facts_hash => {
        :osfamily => 'Suse',
        :operatingsystem => 'SLES',
        :operatingsystemrelease => '12.1',
        :operatingsystemmajrelease => '12',
        :os => {
          'family'       => 'Suse',
          'architecture' => 'i386',
          'release' => {
            'major' => '12',
          },
        },
      },
    },
    'suse11_3' => {
      :extra_packages => [
        'sssd-32bit',
        'sssd-tools',
      ],
      :facts_hash => {
        :osfamily => 'Suse',
        :operatingsystem => 'SLES',
        :operatingsystemrelease => '11.3',
        :operatingsystemmajrelease => '11',
        :os => {
          'family'       => 'Suse',
          'architecture' => 'x86_64',
          'release' => {
            'major' => '11',
            'minor' => '3',
          },
        },
      },
    },
    'suse11_4' => {
      :extra_packages => [
        'sssd-32bit',
        'sssd-tools',
      ],
      :facts_hash => {
        :osfamily => 'Suse',
        :operatingsystem => 'SLES',
        :operatingsystemrelease => '11.4',
        :operatingsystemmajrelease => '11',
        :os => {
          'family'       => 'Suse',
          'architecture' => 'x86_64',
          'release' => {
            'major' => '11',
            'minor' => '4',
          },
        },
      },
    },
    'suse12' => {
      :extra_packages => [
        'sssd-krb5',
        'sssd-ad',
        'sssd-ipa',
        'sssd-32bit',
        'sssd-tools',
        'sssd-ldap',
      ],
      :facts_hash => {
        :osfamily => 'Suse',
        :operatingsystem => 'SLES',
        :operatingsystemrelease => '12.1',
        :operatingsystemmajrelease => '12',
        :os => {
          'family'       => 'Suse',
          'architecture' => 'x86_64',
          'release' => {
            'major' => '12',
          },
        },
      },
    },
    'ubuntu14_04' => {
      :extra_packages => [
        'libpam-runtime',
        'libpam-sss',
        'libnss-sss',
      ],
      :facts_hash => {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '14.04',
        :operatingsystemmajrelease => '14.04',
        :os => {
          'family' => 'Debian',
          'release' => {
            'major' => '14.04',
          },
        },
      },
    },
    'ubuntu16_04' => {
      :extra_packages => [
        'libpam-runtime',
        'libpam-sss',
        'libnss-sss',
      ],
      :facts_hash => {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '16.04',
        :operatingsystemmajrelease => '16.04',
        :os => {
          'family' => 'Debian',
          'release' => {
            'major' => '16.04',
          },
        },
      },
    },
    'ubuntu18_04' => {
      :extra_packages => [
        'libpam-runtime',
        'libpam-sss',
        'libnss-sss',
      ],
      :facts_hash => {
        :osfamily => 'Debian',
        :operatingsystem => 'Ubuntu',
        :operatingsystemrelease => '18.04',
        :operatingsystemmajrelease => '18.04',
        :os => {
          'family' => 'Debian',
          'release' => {
            'major' => '18.04',
          },
        },
      },
    },
  }

  describe 'with default values for parameters on' do
    platforms.sort.each do |k,v|
      context "#{k}" do
        let(:facts) do
          v[:facts_hash]
        end

        it { should compile.with_all_deps }
        it { should contain_class('sssd')}

        it do
          should contain_package('sssd').with({
            :ensure => 'present',
          })
	end
	it do
	  should contain_package('sssd').that_comes_before('File[sssd.conf]')
        end

        if v[:extra_packages]
          v[:extra_packages].each do |pkg|
            it do
              should contain_package(pkg).with({
                :ensure  => 'present',
              })
            end
            it do
              should contain_package(pkg).that_requires('Package[sssd]')
            end
          end
        end

        if v[:service_dependencies]
          if v[:manage_oddjobd] == true
            before = 'Service[oddjobd]'
          else
            before = nil
          end

          v[:service_dependencies].each do |svc|
            it do
              should contain_service(svc).with({
                :ensure     => 'running',
                :hasstatus  => true,
                :hasrestart => true,
                :enable     => true,
                :before     => before,
              })
            end
          end
        end

        if v[:manage_oddjobd] == true
          it do
            should contain_service('oddjobd').with({
              :ensure     => 'running',
              :enable     => true,
              :hasstatus  => true,
              :hasrestart => true,
            })
          end
          if v[:extra_packages]
            it do
              should contain_service('oddjobd').that_requires(
                v[:extra_packages].collect { |pkg| "Package[#{pkg}]" }
              )
            end
          end
        else
          it { is_expected.not_to contain_service('oddjobd') }
        end

        it do
          should contain_file('sssd.conf').with({
            :ensure  => 'file',
            :path    => '/etc/sssd/sssd.conf',
            :owner   => 'root',
            :group   => 'root',
            :mode    => '0600',
            :content => /^# Managed by Puppet.\n\n\[sssd\]\ndomains = example.com\nconfig_file_version = 2\nservices = nss, pam\n\n\[domain\/example.com\]\naccess_provider = simple\nsimple_allow_users = root\n/
          })
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] < '8'
          it do
            should contain_exec('authconfig-mkhomedir').with({
              :command => '/usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --update',
              :unless  => "/usr/bin/test \"`/usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --test`\" = \"`/usr/sbin/authconfig --test`\"",
              :require => 'File[sssd.conf]',
            })
          end
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] == '8'
          it do
            should contain_exec('authselect-mkhomedir').with({
              :command => '/bin/authselect select sssd with-mkhomedir --force',
              :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"sssd with-mkhomedir\"",
              :require => 'File[sssd.conf]',
            })
          end
        end

        if v[:facts_hash][:os]['name'] == 'Fedora'
          it do
            should contain_exec('authselect-mkhomedir').with({
              :command => '/bin/authselect select sssd with-mkhomedir --force',
              :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"sssd with-mkhomedir\"",
              :require => 'File[sssd.conf]',
            })
          end
        end

        if v[:facts_hash][:osfamily] == 'Debian'
          it do
            should contain_file('/usr/share/pam-configs/pam_mkhomedir').with({
              :ensure => 'file',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0644',
              :content => %r{pam_mkhomedir.so umask=0022},
              :notify => 'Exec[pam-auth-update]',
            })
          end

          it do
            should contain_exec('pam-auth-update').with({
              :path        => '/bin:/usr/bin:/sbin:/usr/sbin',
              :refreshonly => true,
            })
          end
        end

        if v[:facts_hash][:osfamily] == 'Suse'

          if v[:facts_hash][:os]['architecture'] == 'i386'
            it do
              should_not contain_package('sssd-32bit').with_ensure('present')
            end
          else
            it do
              should contain_package('sssd-32bit').with_ensure('present')
            end
          end

          it do
            should contain_exec('pam-config -a --mkhomedir').with({
              :path   => '/bin:/usr/bin:/sbin:/usr/sbin',
              :unless => '/usr/sbin/pam-config -q --mkhomedir | grep session:',
            })
          end

          it do
            should contain_exec('pam-config -a --mkhomedir-umask=0022').with({
              :path   => '/bin:/usr/bin:/sbin:/usr/sbin',
              :unless => '/usr/sbin/pam-config -q --mkhomedir | grep umask=0022',
            })
          end

          it do
            should contain_exec('pam-config -a --sss').with({
              :path   => '/bin:/usr/bin:/sbin:/usr/sbin',
              :unless => '/usr/sbin/pam-config -q --sss | grep session:',
            })
          end
        end

        it do
          should contain_service('sssd').with({
            :ensure     => 'running',
            :enable     => true,
            :hasstatus  => true,
            :hasrestart => true,
            :subscribe  => 'File[sssd.conf]',
          })
        end
      end
    end
  end

  describe 'with ensure set to valid string absent' do
    let(:params) { { :ensure => 'absent' } }
    it { should contain_file('sssd.conf').with_ensure('absent') }

    it do
      should contain_exec('authconfig-mkhomedir').with({
        :command => '/usr/sbin/authconfig --disablesssd --disablesssdauth --update',
        :unless  => "/usr/bin/test \"`/usr/sbin/authconfig --disablesssd --disablesssdauth --test`\" = \"`/usr/sbin/authconfig --test`\"",
      })
    end
  end

  describe 'with config set to valid hash' do
    let(:params) { { :config => { 'test' => { 'domains' => 'test.domain.local', 'config_file_version' => 242, 'services' => ['test1', 'test2'], }, } } }
    it { should contain_file('sssd.conf').with_content(/^# Managed by Puppet.\n\n\[test\]\ndomains = test.domain.local\nconfig_file_version = 242\nservices = test1, test2\n/) }
  end

  describe 'with sssd_package set to valid string sssd-test' do
    let(:params) { { :sssd_package => 'sssd-test' } }
    it { should contain_package('sssd-test') }
    it { should contain_package('authconfig').that_requires('Package[sssd-test]') }
  end

  describe 'with sssd_package_ensure set to valid string absent' do
    let(:params) { { :sssd_package_ensure => 'absent' } }
    it { should contain_package('sssd').with_ensure('absent') }
  end

  describe 'with sssd_service set to valid string sssd-test' do
    let(:params) { { :sssd_service => 'sssd-test' } }
    it { should contain_service('sssd-test') }
  end

  describe 'with extra_packages set to valid array [test1, test2]' do
    let(:params) { { :extra_packages => [ 'test1', 'test2' ] } }
    it { should contain_package('test1') }
    it { should contain_package('test2') }
  end

  describe 'with extra_packages_ensure set to valid string absent' do
    let(:params) { { :extra_packages_ensure => 'absent' } }
    it { should contain_package('authconfig').with_ensure('absent') }
    it { should contain_package('oddjob-mkhomedir').with_ensure('absent') }
  end

  describe 'with config_file set to valid absolute path /test/sssd/sssd.conf' do
    let(:params) { { :config_file => '/test/sssd/sssd.conf' } }
    it { should contain_file('sssd.conf').with_path('/test/sssd/sssd.conf') }
  end

  # testing config_template would need an existing template files
  describe 'with config_template set to valid string sssd/sssd.conf.sorted.erb' do
  end

  describe 'with mkhomedir set to valid boolean false' do
    let(:params) { { :mkhomedir => false } }
    it { should_not contain_service('oddjobd') }

    platforms.sort.each do |k,v|
      context "on #{k}" do
        let(:facts) do
          v[:facts_hash]
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and  v[:facts_hash][:os]['release']['major'] < '8'
          it do
            should contain_exec('authconfig-mkhomedir').with({
              :command => '/usr/sbin/authconfig --enablesssd --enablesssdauth --disablemkhomedir --update',
              :unless  => "/usr/bin/test \"`/usr/sbin/authconfig --enablesssd --enablesssdauth --disablemkhomedir --test`\" = \"`/usr/sbin/authconfig --test`\"",
            })
          end
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] == '8'
          it do
            should contain_exec('authselect-mkhomedir').with({
              :command => '/bin/authselect select sssd --force',
              :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"sssd\"",
            })
          end
        end

        if v[:facts_hash][:os]['name'] == 'Fedora'
          it do
            should contain_exec('authselect-mkhomedir').with({
              :command => '/bin/authselect select sssd --force',
              :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"sssd\"",
            })
          end
        end

        if v[:facts_hash][:osfamily] == 'Debian'
          it { should_not contain_file('/usr/share/pam-configs/pam_mkhomedir') }
        end

        if v[:facts_hash][:osfamily] == 'Suse'
          it { should_not contain_exec('pam-config -a --mkhomedir') }
        end
      end
    end
  end

  platforms.sort.each do |k,v|
    describe "with manage_oddjobd set to valid boolean false on #{k}" do
      let(:facts) do
        v[:facts_hash]
      end
      let(:params) { { :manage_oddjobd => false } }

      if v[:service_dependencies]
        v[:service_dependencies].each do |svc|
          it { should contain_service(svc).with_before(nil) }
        end
      end
      it { should_not contain_service('oddjobd') }
    end
  end

  platforms.sort.each do |k,v|
    describe "with manage_oddjobd set to valid boolean true on #{k}" do
      let(:facts) do
        v[:facts_hash]
      end
      let(:params) { { :manage_oddjobd => true } }

      if v[:service_dependencies]
        v[:service_dependencies].each do |svc|
          it { should contain_service(svc).with_before('Service[oddjobd]') }
        end
      end
      it { should contain_service('oddjobd') }
    end
  end

  describe 'with service_ensure set to valid string stopped' do
    let(:params) { { :service_ensure => 'stopped' } }
    it { should contain_service('oddjobd').with_ensure('stopped') }
    it do
      should contain_service('sssd').with({
        :ensure     => 'stopped',
        :enable     => false,
      })
    end
  end

  describe 'with service_dependencies set to valid array [ test1, test2 ]' do
    let(:params) { { :service_dependencies => [ 'test1', 'test2' ] } }
    it { should contain_service('test1') }
    it { should contain_service('test2') }
  end

  describe 'with enable_mkhomedir_flags set to valid array [ --enable1, --enable2 ] and authselect_profile set to valid string profile' do
    let(:params) { { :enable_mkhomedir_flags => [ '--enable1', '--enable2' ] , :authselect_profile => 'profile' } }

    platforms.sort.each do |k, v|
      context "on #{k}" do
        let(:facts) do
          v[:facts_hash]
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] < '8'
          it do
            should contain_exec('authconfig-mkhomedir').with({
              :command => '/usr/sbin/authconfig --enable1 --enable2 --update',
              :unless  => "/usr/bin/test \"`/usr/sbin/authconfig --enable1 --enable2 --test`\" = \"`/usr/sbin/authconfig --test`\"",
            })
          end
        end
        if v[:facts_hash][:os]['name'] == 'Fedora'
          it do
            should contain_exec('authselect-mkhomedir').with({
            :command => '/bin/authselect select profile --enable1 --enable2 --force',
            :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"profile --enable1 --enable2\"",
            })
          end
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] == '8'
          it do
            should contain_exec('authselect-mkhomedir').with({
            :command => '/bin/authselect select profile --enable1 --enable2 --force',
            :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"profile --enable1 --enable2\"",
            })
          end
        end
      end
    end
  end

  describe 'with disable_mkhomedir_flags set to valid array [ --disable1, --disable2 ] and mkhomedir set to false and authselect_profile set to profile' do
    let(:params) { { :disable_mkhomedir_flags => [ '--disable1', '--disable2' ], :mkhomedir => false, :authselect_profile => 'profile' } }

    platforms.sort.each do |k, v|
      context "on #{k}" do
        let(:facts) do
          v[:facts_hash]
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] < '8'
          it do
            should contain_exec('authconfig-mkhomedir').with({
              :command => '/usr/sbin/authconfig --disable1 --disable2 --update',
              :unless  => "/usr/bin/test \"`/usr/sbin/authconfig --disable1 --disable2 --test`\" = \"`/usr/sbin/authconfig --test`\"",
            })
          end
        end
        if v[:facts_hash][:os]['name'] == 'Fedora'
          it do
            should contain_exec('authselect-mkhomedir').with({
            :command => '/bin/authselect select profile --disable1 --disable2 --force',
            :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"profile --disable1 --disable2\"",
            })
          end
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] == '8'
          it do
            should contain_exec('authselect-mkhomedir').with({
            :command => '/bin/authselect select profile --disable1 --disable2 --force',
            :unless  => "/usr/bin/test \"`/bin/authselect current --raw`\" = \"profile --disable1 --disable2\"",
            })
          end
        end
      end
    end
  end

  describe 'with ensure_absent_flags set to valid array [ --absent1, --absent2 ] (and ensure set to absent)' do
    let(:params) { { :ensure_absent_flags => [ '--absent1', '--absent2' ], :ensure => 'absent' } }

    platforms.sort.each do |k, v|
      context "on #{k}" do
        let(:facts) do
          v[:facts_hash]
        end

        if v[:facts_hash][:os]['name'] == 'RedHat' and v[:facts_hash][:os]['release']['major'] < '8'
          it do
            should contain_exec('authconfig-mkhomedir').with({
              :command => '/usr/sbin/authconfig --absent1 --absent2 --update',
              :unless  => "/usr/bin/test \"`/usr/sbin/authconfig --absent1 --absent2 --test`\" = \"`/usr/sbin/authconfig --test`\"",
            })
          end
        end
      end
    end
  end

  describe 'with pam_mkhomedir_umask set to 0077' do
    let(:params) {{:pam_mkhomedir_umask => '0077'}}

    platforms.sort.each do |k, v|
      context "on #{k}" do
        let(:facts) do
          v[:facts_hash]
        end

        if v[:facts_hash][:osfamily] == 'Debian'
          it do
            should contain_file('/usr/share/pam-configs/pam_mkhomedir').with({
              :ensure => 'file',
              :owner => 'root',
              :group => 'root',
              :mode => '0644',
              :content => %r{pam_mkhomedir.so umask=0077},
              :notify => 'Exec[pam-auth-update]',
            })
          end
        end

        if v[:facts_hash][:osfamily] == 'Suse'
          it do
            should contain_exec('pam-config -a --mkhomedir-umask=0077').with({
              :path => '/bin:/usr/bin:/sbin:/usr/sbin',
              :unless => '/usr/sbin/pam-config -q --mkhomedir | grep umask=0077',
            })
          end
        end
      end
    end
  end


  describe 'on unsupported version of' do
    context 'Amazon Linux (not 2)' do
      let(:facts) do
        {
          :osfamily => 'RedHat',
          :operatingsystem => 'Amazon',
          :operatingsystemmajrelease => '1',
          :os => {
            'family' => 'RedHat',
            'name'   => 'Amazon',
            'release' => {
              'major' => '1',
            }
          },
        }
      end

      it 'unsupported Amazon Linux should still pass' do
        expect do
          should contain_class('sssd')
        end
      end
    end

    context 'Debian (not 8 or 9 or Ubuntu 14.04, 16.04 or 18.04)' do
      let(:facts) do
        {
          :osfamily => 'Debian',
          :operatingsystem => 'Debian',
          :operatingsystemmajrelease => '6',
          :os => {
            'family' => 'Debian',
            'release' => {
              'major' => '6',
            }
          },
        }
      end

      it 'unsupported Debian / Ubuntu should still pass' do
        expect do
          should contain_class('sssd')
        end
      end
    end

    context 'RedHat (not 6 or 7)' do
      let(:facts) do
        {
          :osfamily => 'RedHat',
          :operatingsystem => 'RedHat',
          :operatingsystemmajrelease => '4',
          :os => {
            'family' => 'RedHat',
            'release' => {
              'major' => '4',
            }
          },
        }
      end

      it 'unsupported EL should still pass' do
        expect do
          should contain_class('sssd')
        end
      end
    end

    context 'Suse (not 11 or 12)' do
      let(:facts) do
        {
          :osfamily => 'Suse',
          :operatingsystem => 'Suse',
          :operatingsystemmajrelease => '10',
          :os => {
            'family' => 'Suse',
            'release' => {
              'major' => '10',
              'minor' => '0',
            }
          },
        }
      end

      it 'unsupported Suse should still pass' do
        expect do
          should contain_class('sssd')
        end
      end
    end

    context 'Suse 11 (not 11.3 and 11.4)' do
      let(:facts) do
        {
          :osfamily => 'Suse',
          :operatingsystem => 'Suse',
          :operatingsystemmajrelease => '11',
          :operatingsystemrelease => '11.1',
          :os => {
            'family' => 'Suse',
            'release' => {
              'major' => '11',
              'minor' => '1',
            },
          },
        }
      end

      it 'unsupported Suse 11 should still pass' do
        expect do
          should contain_class('sssd')
        end
      end
    end
  end

  describe 'variable type and content validations' do
    mandatory_params = {}

    validations = {
      'array' => {
        :name    => %w(extra_packages service_dependencies enable_mkhomedir_flags disable_mkhomedir_flags ensure_absent_flags ),
        :valid   => [%w(ar ray)],
        :invalid => ['invalid', { 'ha' => 'sh' }, 3, 2.42, true, nil],
        :message => 'expects an Array value',
      },
      'absolute_path' => {
        :name    => %w[config_file],
        :valid   => %w[/absolute/filepath /absolute/directory/],
        :invalid => ['./relative/path', %w(ar ray), { 'ha' => 'sh' }, 3, 2.42, true, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
      'boolean' => {
        :name    => %w(mkhomedir manage_oddjobd),
        :valid   => [true, false],
        :invalid => ['false', %w(ar ray), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
      'hash' => {
        :name    => %w(config),
        :valid   => [], # valid hashes are to complex to block test them here.
        :invalid => ['string', 3, 2.42, %w(ar ray), true, nil],
        :message => 'expects a Hash value',
      },
      # testing config_template would need existing template files
      'string' => {
        :name    => %w[sssd_package sssd_package_ensure sssd_service extra_packages_ensure authselect_profile],
        :valid   => %w[string],
        :invalid => [%w(ar ray), { 'ha' => 'sh' }, 3, 2.42, true],
        :message => 'expects a String',
      },
      'validate_re ensure' => {
        :name    => %w[ensure],
        :valid   => %w[absent present],
        :invalid => ['string', %w(ar ray), { 'ha' => 'sh' }, 3, 2.42, true, nil],
        :message => 'expects a match for Enum',
      },
      'validate_re service_ensure' => {
        :name    => %w[service_ensure],
        :valid   => [true, false, 'running', 'stopped'],
        :invalid => ['string', %w(ar ray), { 'ha' => 'sh' }, 3, 2.42, nil],
        :message => 'Evaluation Error: Error while evaluating a Resource Statement',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:params] = {} if var[:params].nil?
        var[:valid].each do |valid|
          context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => valid, }].reduce(:merge) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { [mandatory_params, var[:params], { :"#{var_name}" => invalid, }].reduce(:merge) }
            it 'should fail' do
              expect { should contain_class(subject) }.to raise_error(Puppet::PreformattedError, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'
end
