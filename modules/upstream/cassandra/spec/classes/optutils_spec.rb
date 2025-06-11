require 'spec_helper'
describe 'cassandra::optutils' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'RedHat',
        os: {
          'family' => 'RedHat',
          'name' => 'RedHat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    it do
      is_expected.to have_resource_count(7)
      is_expected.to contain_package('cassandra22-tools').with(ensure: 'present')

      is_expected.to contain_class('cassandra::optutils').with(
        package_ensure: 'present',
        package_name: 'cassandra22-tools'
      )
    end
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'Debian',
        os: {
          'family' => 'Debian',
          'name' => 'Debian',
          'release' => {
            'full'  => '7.8',
            'major' => '7',
            'minor' => '8'
          }
        }
      }
    end

    it do
      is_expected.to contain_package('cassandra-tools').with(ensure: 'present')

      is_expected.to contain_class('cassandra::optutils').with(
        package_ensure: 'present',
        package_name: 'cassandra-tools'
      )
    end
  end

  context 'With package_name set to foobar' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'Debian',
        os: {
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
        package_name: 'foobar-java',
        package_ensure: '42'
      }
    end

    it do
      is_expected.to contain_package('foobar-java').with(ensure: 42)
    end
  end

  context 'On a Debian OS with package_ensure set' do
    let :facts do
      {
        operatingsystemmajrelease: '7',
        osfamily: 'Debian',
        os: {
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

    it { is_expected.to contain_package('cassandra-tools').with_ensure('2.1.13') }
  end
end
