require 'beaker-rspec'
require 'pry'

class TestManifests
  def initialize(roles, version, operatingsystemmajrelease)
    # Instance variables
    @roles = roles
    @version = version

    if version == 2.1
      init21
    elsif version == 2.2
      init22
    elsif version == 3.0
      init30(operatingsystemmajrelease)
    end
  end

  def init21
    @debian_release = '21x'
    @debian_package_ensure = '2.1.18'
    @redhat_package_ensure = '2.1.15-1'
    @cassandra_optutils_package = 'cassandra21-tools'
    @cassandra_package = 'cassandra21'
  end

  def init22
    @debian_release = '22x'
    @debian_package_ensure = '2.2.10'
    @redhat_package_ensure = '2.2.8-1'
    @cassandra_optutils_package = 'cassandra22-tools'
    @cassandra_package = 'cassandra22'
  end

  def init30(operatingsystemmajrelease)
    @debian_release = '30x'
    @debian_package_ensure = '3.0.14'
    print "operatingsystemmajrelease := #{operatingsystemmajrelease}"

    if operatingsystemmajrelease == '6'
      @redhat_package_ensure = '3.0.9-1'
      @cassandra_optutils_package = 'cassandra30-tools'
      @cassandra_package = 'cassandra30'
    else
      @redhat_release = '30x'
      @redhat_package_ensure = '3.0.14-1'
      @cassandra_optutils_package = 'cassandra-tools'
      @cassandra_package = 'cassandra'
    end
  end

  def bootstrap_pp
    <<-EOS
    Exec {
      path => [
       '/usr/local/bin',
       '/opt/local/bin',
       '/usr/bin',
       '/usr/sbin',
       '/bin',
       '/sbin'],
       logoutput => true,
    }

    notify { "${::hostname}:${::operatingsystem}-${::operatingsystemmajrelease}": }

    file { '/etc/dse':
      ensure => directory,
    } ->
    file { '/etc/dse/dse-env.sh':
      ensure  => present,
      content => "#export DSE_HOME\n# export HADOOP_LOG_DIR=<log_dir>",
    }

    case downcase("${::operatingsystem}-${::operatingsystemmajrelease}") {
      'centos-6': {
        package { ['gcc', 'tar', 'yum-utils', 'centos-release-scl']: } ->
        exec { 'yum-config-manager --enable rhel-server-rhscl-7-rpms': } ->
        package { 'ruby200': } ->
        package { 'python27-python':
          ensure => '2.7.8-18.el6',
        } ->
        exec { 'cp /opt/rh/python27/enable /etc/profile.d/python.sh': } ->
        exec { 'echo "\n" >> /etc/profile.d/python.sh': } ->
        exec { 'echo "export PYTHONPATH=/usr/lib/python2.7/site-packages" >> /etc/profile.d/python.sh': } ->
        exec { '/bin/cp /opt/rh/ruby200/enable /etc/profile.d/ruby.sh': } ->
        exec { '/bin/rm /usr/bin/ruby /usr/bin/gem': } ->
        exec { '/usr/sbin/alternatives --install /usr/bin/ruby ruby /opt/rh/ruby200/root/usr/bin/ruby 1000': } ->
        exec { '/usr/sbin/alternatives --install /usr/bin/gem gem /opt/rh/ruby200/root/usr/bin/gem 1000': }
      }
      'centos-7': {
        package { ['gcc', 'tar', 'initscripts']: }
      }
      'debian-7': {
        package { ['sudo', 'ufw', 'wget']: }
      }
      'debian-8': {
        package { ['locales-all', 'net-tools', 'sudo', 'ufw']: } ->
        file { '/usr/sbin/policy-rc.d':
          ensure => absent,
        }
      }
      'ubuntu-12.04': {
        package {['python-software-properties', 'iptables', 'sudo']:} ->
        exec {'/usr/bin/apt-add-repository ppa:brightbox/ruby-ng':} ->
        exec {'/usr/bin/apt-get update': } ->
        package {'ruby2.0': } ->
        exec { '/bin/rm /usr/bin/ruby': } ->
        exec { '/usr/sbin/update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.0 1000': }
      }
      'ubuntu-16.04': {
        package { ['locales-all', 'net-tools', 'sudo', 'ufw']: } ->
        file { '/usr/sbin/policy-rc.d':
          ensure => absent,
        }
      }
    }
    EOS
  end

  def cassandra_install_pp
    <<-EOS
    if $::osfamily == 'Debian' {
      class { 'cassandra::apache_repo':
        release => '#{@debian_release}',
        before  => Class['cassandra', 'cassandra::optutils'],
      }

      $package_ensure = '#{@debian_package_ensure}'
      $cassandra_package = 'cassandra'
      $cassandra_optutils_package = 'cassandra-tools'
    } else {
      if #{@version} >= 3.0 and $::operatingsystemmajrelease >= 7 {
        yumrepo { 'datastax':
          ensure => absent,
        } ->
        class { 'cassandra::apache_repo':
          release => '#{@redhat_release}',
          before  => Class['cassandra', 'cassandra::optutils'],
        }
      } else {
        class { 'cassandra::datastax_repo':
          before  => Class['cassandra', 'cassandra::optutils'],
        }
      }

      $package_ensure = '#{@redhat_package_ensure}'
      $cassandra_package = '#{@cassandra_package}'
      $cassandra_optutils_package = '#{@cassandra_optutils_package}'
    }

    require cassandra::system::swapoff
    require cassandra::system::transparent_hugepage
    include cassandra::java

    if versioncmp($::rubyversion, '1.9.0') < 0 {
      $service_refresh = false
    } else {
      $service_refresh = true
    }

    if #{@version} >= 3.0 {
      class { 'cassandra':
        hints_directory => '/var/lib/cassandra/hints',
        package_ensure  => $package_ensure,
        package_name    => $cassandra_package,
        service_refresh => $service_refresh,
        require         => Class['cassandra::java'],
      }
    } else {
      class { 'cassandra':
        package_ensure  => $package_ensure,
        package_name    => $cassandra_package,
        service_refresh => $service_refresh,
        require         => Class['cassandra::java'],
      }
    }

    class { 'cassandra::optutils':
      package_ensure => $package_ensure,
      package_name   => $cassandra_optutils_package,
      require        => Class['cassandra']
    }

    if $::osfamily == 'RedHat' {
      class { 'cassandra::datastax_agent':
        require => Class['cassandra']
      }
    }

    #{firewall_pp}
    include cassandra::dse
    EOS
  end

  def cassandra_uninstall_pp
    <<-EOS
      Exec {
        path => [
          '/usr/bin',
          '/bin' ],
        logoutput => true,
      }
      if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = '#{@cassandra_optutils_package}'
        $cassandra_package = '#{@cassandra_package}'
      } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
      }
      service { 'cassandra':
        ensure => stopped,
      } ->
      package { $cassandra_optutils_package:
        ensure => purged,
      } ->
      package { $cassandra_package:
        ensure => purged,
      } ->
      exec { 'rm -rf /var/lib/cassandra/*/* /var/log/cassandra/*': }
    EOS
  end

  def facts_testing_pp
    <<-EOS
      #{cassandra_install_pp}

      if $::osfamily == 'Debian' {
        $package_comparison = $cassandrarelease
      } else {
        $package_comparison = "${cassandrarelease}-1"
      }

      if $package_comparison != $package_ensure {
        fail("cassandrarelease: ${package_comparison} != ${package_ensure}")
      }

      if $::cassandramaxheapsize <= 0 {
        fail('cassandramaxheapsize is not set.')
      }
      if $::cassandracmsmaxheapsize <= 0 {
        fail('cassandracmsmaxheapsize is not set.')
      }
      if $::cassandraheapnewsize <= 0 {
        fail('cassandraheapnewsize is not set.')
      }
      if $::cassandracmsheapnewsize <= 0 {
        fail('cassandracmsheapnewsize is not set.')
      }
    EOS
  end

  def firewall_pp
    pp = if @roles.include? 'firewall'
           <<-EOS
            class { '::cassandra::firewall_ports':
              require => Class['::cassandra'],
            }
          EOS
         else
           <<-EOS
            # Firewall test skipped
          EOS
         end
    pp
  end

  def permissions_revoke_pp
    <<-EOS
      #{cassandra_install_pp}
      class { 'cassandra::schema':
        cqlsh_password      => 'Niner2',
        cqlsh_user          => 'akers',
        cqlsh_client_config => '/root/.puppetcqlshrc',
        permissions    => {
          'Revoke select permissions to spillman to all keyspaces' => {
            ensure          => absent,
            permission_name => 'SELECT',
            user_name       => 'spillman',
          },
          'Revoke modify to to keyspace mykeyspace to akers'       => {
            ensure          => absent,
            keyspace_name   => 'mykeyspace',
            permission_name => 'MODIFY',
            user_name       => 'akers',
          },
          'Revoke alter permissions to mykeyspace to boone'        => {
            ensure          => absent,
            keyspace_name   => 'mykeyspace',
            permission_name => 'ALTER',
            user_name       => 'boone',
          },
          'Revoke ALL permissions to mykeyspace.users to gbennet'  => {
            ensure          => absent,
            keyspace_name   => 'mykeyspace',
            permission_name => 'ALTER',
            table_name      => 'users',
            user_name       => 'gbennet',
          },
        },
      }
    EOS
  end

  def schema_create_pp
    <<-EOS
      #{cassandra_install_pp}

      $cql_types = {
        'fullname' => {
          'keyspace' => 'mykeyspace',
          'fields'   => {
          'fname' => 'text',
            'lname' => 'text',
          },
        },
      }
      $keyspaces = {
        'mykeyspace' => {
          ensure          => present,
          replication_map => {
            keyspace_class     => 'SimpleStrategy',
            replication_factor => 1,
          },
          durable_writes  => false,
        },
      }
      class { 'cassandra::schema':
        cql_types      => $cql_types,
        cqlsh_password => 'cassandra',
        cqlsh_user     => 'cassandra',
        indexes        => {
          'users_lname_idx' => {
            keyspace => 'mykeyspace',
            table    => 'users',
            keys     => 'lname',
          },
        },
        keyspaces      => $keyspaces,
        tables         => {
          'users' => {
            'keyspace' => 'mykeyspace',
            'columns'  => {
              'userid'      => 'int',
              'fname'       => 'text',
              'lname'       => 'text',
              'PRIMARY KEY' => '(userid)',
            },
          },
        },
        permissions    => {
          'Grant select permissions to spillman to all keyspaces' => {
            permission_name => 'SELECT',
            user_name       => 'spillman',
          },
          'Grant modify to to keyspace mykeyspace to akers'       => {
            keyspace_name   => 'mykeyspace',
            permission_name => 'MODIFY',
            user_name       => 'akers',
          },
          'Grant alter permissions to mykeyspace to boone'        => {
            keyspace_name   => 'mykeyspace',
            permission_name => 'ALTER',
            user_name       => 'boone',
          },
          'Grant ALL permissions to mykeyspace.users to gbennet'  => {
            keyspace_name   => 'mykeyspace',
            permission_name => 'ALTER',
            table_name      => 'users',
            user_name       => 'gbennet',
          },
        },
        users          => {
          'akers'    => {
            password  => 'Niner2',
            superuser => true,
          },
          'boone'    => {
            password => 'Niner75',
          },
          'gbennet' => {
            password => 'Strewth',
          },
          'spillman' => {
            password => 'Niner27',
          },
          'bob' => {
            password => 'kaZe89a',
            login    => false,
          },
          'john' => {
            superuser => true,
            password  => 'kaZe89a',
            login     => true,
          },
        },
      }
    EOS
  end

  def schema_drop_index_pp
    <<-EOS
      #{cassandra_install_pp}
      class { 'cassandra::schema':
        cqlsh_user     => 'akers',
        cqlsh_password => 'Niner2',
        indexes        => {
          'users_lname_idx' => {
            ensure   => absent,
            keyspace => 'mykeyspace',
            table    => 'users',
          },
        },
      }
    EOS
  end

  def schema_drop_table_pp
    <<-EOS
      #{cassandra_install_pp}
      class { 'cassandra::schema':
        cqlsh_password => 'Niner2',
        cqlsh_user     => 'akers',
        tables         => {
          'users' => {
            ensure   => absent,
            keyspace => 'mykeyspace',
          },
        },
      }
    EOS
  end

  def schema_drop_keyspace_pp
    <<-EOS
      #{cassandra_install_pp}
      $keyspaces = {
        'mykeyspace' => {
          ensure => absent,
        }
      }
      class { 'cassandra::schema':
        cqlsh_password => 'Niner2',
        cqlsh_user     => 'akers',
        keyspaces      => $keyspaces,
      }
    EOS
  end

  def schema_drop_type_pp
    pp = <<-EOS
      #{cassandra_install_pp}
      $cql_types = {
       'fullname' => {
         'keyspace' => 'mykeyspace',
         'ensure'   => 'absent'
       }
      }
      class { 'cassandra::schema':
       cql_types      => $cql_types,
       cqlsh_user     => 'akers',
       cqlsh_password => 'Niner2',
      }
    EOS
    pp
  end

  def schema_drop_user_pp
    pp = <<-EOS
      #{cassandra_install_pp}
      class { 'cassandra::schema':
        cqlsh_password      => 'Niner2',
        cqlsh_user          => 'akers',
        cqlsh_client_config => '/root/.puppetcqlshrc',
        users               => {
          'boone' => {
            ensure => absent,
          },
        },
      }
    EOS
    pp
  end
end

hosts.each do |host|
  case host.name
  when 'ubuntu1604'
    host.install_package('puppet')
  else
    install_puppet_on(host)
  end
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install modules
    puppet_module_install(source: module_root, module_name: 'cassandra')
    hosts.each do |host|
      on host, puppet('module', 'install',
                      'puppetlabs-apt'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-firewall'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-inifile'), acceptable_exit_codes: [0, 1]
      on host, puppet('module', 'install',
                      'puppetlabs-stdlib'), acceptable_exit_codes: [0, 1]
      # Install hiera
      write_hiera_config_on(host,
                            [
                              'environments/%{environment}/data/fqdn/%{fqdn}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/%{lsbdistcodename}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/%{lsbmajdistrelease}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/%{architecture}',
                              'environments/%{environment}/data/osfamily/%{osfamily}/common',
                              # 'environments/%{environment}/data/modules/%{cname}',
                              'environments/%{environment}/data/modules/%{caller_module_name}',
                              'environments/%{environment}/data/modules/%{module_name}',
                              'environments/%{environment}/data/common'
                            ])
      copy_hiera_data_to(host, './spec/acceptance/hieradata/')
    end
  end
end
