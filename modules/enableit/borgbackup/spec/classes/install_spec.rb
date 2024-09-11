

require 'spec_helper'

describe 'borgbackup::install' do
  let :default_params do
      { :packages       => ['borgbackup'],
        :package_ensure => 'installed',
      }
  end

  shared_examples 'borgbackup::install shared examples' do

    it { is_expected.to compile.with_all_deps }

  end

  context 'with defaults' do
    let :params do
      default_params
    end 

    it_behaves_like 'borgbackup::install shared examples'

    it 'installs borgbackup' do
      is_expected.to contain_package( 'borgbackup' )
	.with_ensure( params[:package_ensure] )
        .with_tag('borgbackup')
    end
  end

  context 'with non  defaults' do
    let :params do
      default_params.merge( 
	:packages       => ['backup-whatever'],
        :package_ensure => 'actual',
      )
    end
    it_behaves_like 'borgbackup::install shared examples'

    it 'installs borgbackup' do
      is_expected.to contain_package( 'backup-whatever' )
	.with_ensure( params[:package_ensure] )
        .with_tag('borgbackup')
    end
  end

end
