require File.join(File.dirname(__FILE__), '..', 'spec_helper').to_s
describe 'perforce' do
  context 'default parameters' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('perforce::install') }
    it { is_expected.to contain_class('perforce::configure') }
    it { is_expected.to contain_class('perforce::package') }
    it { is_expected.to contain_class('perforce::repository') }
    it { is_expected.to contain_class('perforce::license') }
    it { is_expected.to contain_class('perforce::service') }

    # perforce's main yum repository
    it { is_expected.to contain_yumrepo('perforce') }

    # package installation
    it { is_expected.to contain_package('helix-p4d') }
    it { is_expected.to contain_package('helix-cli') }

    # perforce p4d service
    it { is_expected.to contain_service('p4d') }

    # perforce p4d environment variables, configuration
    it { is_expected.to contain_file('/opt/perforce/.p4config') }
  end

  context 'with ssl' do
    let(:params) do
      { 'service_ssldir' => '/opt/perforce/p4ssldir' }
    end

    # perforce ssl directory environment variable is set
    it { is_expected.to contain_file('/opt/perforce/.p4config').with_content(%r{^P4SSLDIR}) }

    # perforce daemon configured to run on ssl
    it { is_expected.to contain_file('/opt/perforce/.p4config').with_content(%r{ssl:1666}) }
  end

  context 'with license' do
    let(:params) do
      { 'license_content'	=> 'License:	1234567890ABCDEFGHIJK' }
    end

    # is_expected.to create a license file in the perforce root directory
    it { is_expected.to contain_file('/opt/perforce/p4root/license').with_content(%r{License:	1234567890ABCDEFGHIJK}) }
  end
end
