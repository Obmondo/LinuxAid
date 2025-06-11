require 'spec_helper'
describe 'cassandra::java' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'RedHat',
        os: {
          'family'  => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    it do
      is_expected.to contain_class('cassandra::java')
      is_expected.to contain_package('java-1.8.0-openjdk-headless')
      is_expected.to contain_package('jna')
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'Debian',
        lsbdistid: 'Debian',
        os: {
          'name'    => 'Debian',
          'family'  => 'Debian',
          'release' => {
            'full'  => '7.8',
            'major' => '7',
            'minor' => '8'
          }
        }
      }
    end

    it do
      is_expected.to contain_class('cassandra::java')
      is_expected.to contain_package('openjdk-7-jre-headless')
      is_expected.to contain_package('libjna-java')
      is_expected.to have_resource_count(2)
    end
  end

  context 'On a Debian OS with package_ensure set' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'Debian',
        lsbdistid: 'Debian',
        os: {
          'name'    => 'Debian',
          'family'  => 'Debian',
          'release' => {
            'full'  => '7.8',
            'major' => '7',
            'minor' => '8'
          }
        }
      }
    end

    let :params do
      {
        package_ensure: '2.1.13'
      }
    end

    it do
      is_expected.to contain_package('openjdk-7-jre-headless').with_ensure('2.1.13')
    end
  end

  context 'With package names set to foobar' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'RedHat',
        os: {
          'family'  => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let :params do
      {
        package_name: 'foobar-java',
        package_ensure: '42',
        jna_package_name: 'foobar-jna',
        jna_ensure: 'latest'
      }
    end

    it do
      is_expected.to contain_package('foobar-java').with(ensure: 42)
      is_expected.to contain_package('foobar-jna').with(ensure: 'latest')
    end
  end

  context 'Ensure that a YUM repo can be specified.' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'RedHat',
        os: {
          'family'  => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    let :params do
      {
        yumrepo: {
          'ACME' => {
            'baseurl' => 'http://yum.acme.org/repos',
            'descr'   => 'YUM Repository for ACME Products'
          }
        }
      }
    end

    it do
      is_expected.to contain_yumrepo('ACME').with(
        baseurl: 'http://yum.acme.org/repos',
        descr: 'YUM Repository for ACME Products'
      ).that_comes_before('Package[java-1.8.0-openjdk-headless]')
    end
  end

  context 'Ensure that Apt key and source can be specified.' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'Debian',
        lsbdistid: 'Debian',
        os: {
          'name'    => 'Debian',
          'family'  => 'Debian',
          'release' => {
            'full'  => '7.8',
            'major' => '7',
            'minor' => '8'
          }
        }
      }
    end

    let :params do
      {
        aptkey: {
          'openjdk-r' => {
            'id'     => 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
            'server' => 'keyserver.ubuntu.com'
          }
        },
        aptsource: {
          'openjdk-r' => {
            'comment'  => 'OpenJDK builds (all archs)',
            'location' => 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
            'repos'    => 'main',
            'release'  => 'trusty'
          }
        }
      }
    end

    it do
      is_expected.to contain_apt__key('openjdk-r').
        with(
          id: 'DA1A4A13543B466853BAF164EB9B1D8886F44E2A',
          server: 'keyserver.ubuntu.com'
        ).
        that_comes_before('Package[openjdk-7-jre-headless]')
      is_expected.to contain_apt__source('openjdk-r').
        with(
          comment: 'OpenJDK builds (all archs)',
          location: 'http://ppa.launchpad.net/openjdk-r/ppa/ubuntu',
          repos: 'main',
          release: 'trusty'
        )
      is_expected.to contain_exec('cassandra::java::apt_update').
        with(
          refreshonly: true,
          command: '/bin/true'
        ).
        that_comes_before('Package[openjdk-7-jre-headless]')
    end
  end
end
