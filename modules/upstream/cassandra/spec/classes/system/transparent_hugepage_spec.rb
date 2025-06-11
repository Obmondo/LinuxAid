require 'spec_helper'

describe 'cassandra::system::transparent_hugepage' do
  context 'Test the default parameters (RedHat)' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: 7,
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
      is_expected.to have_resource_count(1)
      is_expected.to contain_class('cassandra::system::transparent_hugepage')
      is_expected.to contain_exec('Disable Java Hugepages')
    end
  end

  context 'Test the default parameters (Debian)' do
    let :facts do
      {
        osfamily: 'Debian',
        operatingsystemmajrelease: 7,
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

    it do
      is_expected.to have_resource_count(1)
      is_expected.to contain_class('cassandra::system::transparent_hugepage')
      is_expected.to contain_exec('Disable Java Hugepages')
    end
  end
end
