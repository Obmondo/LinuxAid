require 'spec_helper'
describe 'cassandra::dse' do
  context 'with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: 7,
        os: {
          'family' => 'RedHat',
          'name' => 'Redhat',
          'release' => {
            'full'  => '7.6.1810',
            'major' => '7',
            'minor' => '6'
          }
        }
      }
    end

    it do
      is_expected.to have_resource_count(13)
      is_expected.to contain_class('cassandra')

      is_expected.to contain_class('cassandra::dse').with(
        config_file_mode: '0644',
        config_file: '/etc/dse/dse.yaml'
      )
    end
  end
end
