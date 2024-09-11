require 'spec_helper'

describe 'curator', type: :class do
  it { is_expected.to create_class('curator') }

  it { is_expected.to contain_package('elasticsearch-curator').with(ensure: 'latest') }

  context 'set package version and use default provider' do
    let(:params) { { ensure: '4.0.0' } }

    it { is_expected.to contain_package('elasticsearch-curator').with(ensure: '4.0.0') }
  end

  context 'set package version and package name and use default provider' do
    let(:params) do
      {
        ensure: '4.0.0',
        package_name: 'python-elasticsearch-curator',
      }
    end

    it { is_expected.to contain_package('python-elasticsearch-curator').with(ensure: '4.0.0') }
  end
end
