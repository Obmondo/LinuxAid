require 'spec_helper'

describe 'curator', type: :class do
  let(:params) do
    {
      ensure: '4.1.0',
      manage_repo: true,
      package_name: 'python-elasticsearch-curator',
      repo_version: '4',
    }
  end

  context 'Repo class on RedHat/CentOS' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '7',
      }
    end

    it { is_expected.to create_class('curator::repo') }
    it { is_expected.to contain_yumrepo('curator').with(baseurl: 'http://packages.elastic.co/curator/4/centos/7') }
  end

  context 'Repo class on Debian/Ubuntu' do
    let(:facts) do
      {
        lsbdistid: 'Debian',
        osfamily: 'Debian',
        os: {
          release: {
            major: '8',
          },
        },
      }
    end

    it { is_expected.to create_class('curator::repo') }
    it { is_expected.to contain_apt__source('curator').with(location: 'http://packages.elastic.co/curator/4/debian') }
  end

  context 'set package version and package name and manage repository for yum' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '7',
      }
    end

    it { is_expected.to contain_package('python-elasticsearch-curator').with(ensure: '4.1.0') }
  end

  context 'set package version and package name and manage repository for apt' do
    let(:facts) do
      {
        lsbdistid: 'Debian',
        osfamily: 'Debian',
        os: {
          release: {
            major: '8',
          },
        },
      }
    end

    it { is_expected.to contain_package('python-elasticsearch-curator').with(ensure: '4.1.0') }
  end
end
