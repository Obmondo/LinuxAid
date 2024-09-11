# @api private
# @summary Installs core python packages
#
# @example
#  include python::install
#
class python::install {
  $python = $python::version ? {
    'system'                 => 'python',
    'pypy'                   => 'pypy',
    /\A(python[23]\.[0-9]+)/ => $1,
    /\A(python)?([0-9]+)/    => "python${2}",
    /\Arh-python[0-9]{2}/    => $python::version,
    default                  => "python${python::version}",
  }

  $pythondev = $facts['os']['family'] ? {
    'AIX'     => "${python}-devel",
    'Debian'  => "${python}-dev",
    'FreeBSD' => undef,
    'Gentoo'  => undef,
    'RedHat'  => "${python}-devel",
    'Suse'    => "${python}-devel",
  }

  $pip_ensure = $python::pip ? {
    true    => 'present',
    false   => 'absent',
    default => $python::pip,
  }

  $dev_ensure = $python::dev ? {
    true    => 'present',
    false   => 'absent',
    default => $python::dev,
  }

  if $python::manage_python_package {
    package { 'python':
      ensure => $python::ensure,
      name   => $python,
    }
  }

  case $python::provider {
    'pip': {
      if $python::manage_pip_package {
        package { 'pip':
          ensure  => $pip_ensure,
          require => Package['python'],
        }
      }

      if $pythondev {
        package { 'python-dev':
          ensure => $dev_ensure,
          name   => $pythondev,
        }
      }

      # Respect the $pip_ensure setting
      unless $pip_ensure == 'absent' {
        # Install pip without pip, see https://pip.pypa.io/en/stable/installing/.
        include python::pip::bootstrap

        Exec['bootstrap pip'] -> File['pip-python'] -> Package <| provider == pip |>

        Package <| title == 'pip' |> {
          name     => 'pip',
          provider => 'pip',
        }
      }
    }
    'scl': {
      # SCL is only valid in the RedHat family. If RHEL, package must be
      # enabled using the subscription manager outside of puppet. If CentOS,
      # the centos-release-SCL will install the repository.
      if $python::manage_scl {
        $install_scl_repo_package = $facts['os']['name'] ? {
          'CentOS' => 'present',
          default  => 'absent',
        }

        package { 'centos-release-scl':
          ensure => $install_scl_repo_package,
          before => Package['scl-utils'],
        }

        package { 'scl-utils':
          ensure => 'present',
          before => Package['python'],
        }

        Package['scl-utils'] -> Package["${python}-scldevel"]

        if $pip_ensure != 'absent' {
          Package['scl-utils'] -> Exec['python-scl-pip-install']
        }
      }

      package { "${python}-scldevel":
        ensure => $dev_ensure,
      }

      if $pip_ensure != 'absent' {
        exec { 'python-scl-pip-install':
          command => "${python::exec_prefix}easy_install pip",
          path    => ['/usr/bin', '/bin'],
          creates => "/opt/rh/${python::version}/root/usr/bin/pip",
        }
      }
    }
    'rhscl': {
      # rhscl is RedHat SCLs from softwarecollections.org
      if $python::rhscl_use_public_repository {
        $scl_package = "rhscl-${python::version}-epel-${facts['os']['release']['major']}-${facts['os']['architecture']}"

        package { $scl_package:
          source   => "https://www.softwarecollections.org/en/scls/rhscl/${python::version}/epel-${facts['os']['release']['major']}-${facts['os']['architecture']}/download/${scl_package}.noarch.rpm",
          provider => 'rpm',
          tag      => 'python-scl-repo',
        }
      }

      Package <| title == 'python' |> {
        tag => 'python-scl-package',
      }

      Package <| title == 'virtualenv' |> {
        name => "${python}-python-virtualenv",
      }

      package { "${python}-scldevel":
        ensure => $dev_ensure,
        tag    => 'python-scl-package',
      }

      package { "${python}-python-pip":
        ensure => $pip_ensure,
        tag    => 'python-pip-package',
      }

      if $python::rhscl_use_public_repository {
        Package <| tag == 'python-scl-repo' |>
        -> Package <| tag == 'python-scl-package' |>
      }

      Package <| tag == 'python-scl-package' |> -> Package <| tag == 'python-pip-package' |>
    }
    'anaconda': {
      $installer_path = '/var/tmp/anaconda_installer.sh'

      file { $installer_path:
        source => $python::anaconda_installer_url,
        mode   => '0700',
      }
      -> exec { 'install_anaconda_python':
        command   => "${installer_path} -b -p ${python::anaconda_install_path}",
        creates   => $python::anaconda_install_path,
        logoutput => true,
      }
      -> exec { 'install_anaconda_virtualenv':
        command => "${python::anaconda_install_path}/bin/pip install virtualenv",
        creates => "${python::anaconda_install_path}/bin/virtualenv",
      }
    }
    default: {
      case $facts['os']['family'] {
        'AIX': {
          if String($python::version) =~ /^python3/ {
            class { 'python::pip::bootstrap':
              version => 'pip3',
            }
          } else {
            if $python::manage_pip_package {
              package { 'python-pip':
                ensure   => $pip_ensure,
                require  => Package['python'],
                provider => 'yum',
              }
            }
          }

          if $pythondev {
            package { 'python-dev':
              ensure   => $dev_ensure,
              name     => $pythondev,
              alias    => $pythondev,
              provider => 'yum',
            }
          }
        }
        default: {
          if $python::manage_pip_package {
            package { 'pip':
              ensure  => $pip_ensure,
              require => Package['python'],
            }
          }

          if $pythondev {
            package { 'python-dev':
              ensure => $dev_ensure,
              name   => $pythondev,
              alias  => $pythondev,
            }
          }
        }
      }

      if $facts['os']['family'] == 'RedHat' {
        if $pip_ensure != 'absent' and $python::use_epel and ($python::manage_pip_package or $python::manage_python_package) {
          require epel
        }
      }

      if String($python::version) =~ /^python3/ {
        $pip_category = undef
        $pip_package  = "${python}-pip"
        $pip_provider = $python.regsubst(/^.*python3\.?/,'pip3.').regsubst(/\.$/,'')
      } elsif ($facts['os']['family'] == 'RedHat') and (versioncmp($facts['os']['release']['major'], '8') >= 0) {
        $pip_category = undef
        $pip_package  = 'python3-pip'
        $pip_provider = pip3
      } elsif ($facts['os']['family'] == 'RedHat') and (versioncmp($facts['os']['release']['major'], '7') >= 0) {
        $pip_category = undef
        $pip_package  = 'python2-pip'
        $pip_provider = pip2
      } elsif $facts['os']['family'] == 'FreeBSD' {
        $pip_category = undef
        $pip_package  = "py${python::version}-pip"
        $pip_provider = 'pip'
      } elsif $facts['os']['family'] == 'Gentoo' {
        $pip_category = 'dev-python'
        $pip_package  = 'pip'
        $pip_provider = 'pip'
      } else {
        $pip_package = $facts['os']['release']['major'] ? {
          '20.04' => 'python3-pip',
          default => 'python-pip',
        }
        $pip_category = undef
        $pip_provider = 'pip'
      }

      Package <| title == 'pip' |> {
        name     => $pip_package,
        category => $pip_category,
      }
    }
  }

  if $python::manage_gunicorn {
    $gunicorn_ensure = $python::gunicorn ? {
      true    => 'present',
      false   => 'absent',
      default => $python::gunicorn,
    }

    package { 'gunicorn':
      ensure => $gunicorn_ensure,
      name   => $python::gunicorn_package_name,
    }
  }
}
