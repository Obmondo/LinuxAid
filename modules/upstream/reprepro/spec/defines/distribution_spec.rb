require 'spec_helper'

describe 'reprepro::distribution' do

  let :default_params do
    {
      :repository     => 'localpkgs',
      :origin         => 'Foobar',
      :label          => 'Foobar',
      :suite          => 'precise',
      :architectures  => 'amd64 i386',
      :components     => 'main contrib non-free',
      :description    => 'Package repository for local site maintenance',
      :sign_with      => 'F4D5DAA8',
      :basedir        => '/var/packages',
      :not_automatic  => 'No',
      :install_cron   => true,
    }
  end

  context "With default parameters" do
    let(:title) { 'precise' }
    let :params do
      default_params.merge({
        :name     => 'precise',
        :codename => 'precise'
      })
    end

    it { should contain_class('reprepro::params') }
    it { should contain_class('concat::setup') }

    it do
      should contain_concat__fragment('distribution-precise').with({
        :target => '/var/packages/localpkgs/conf/distributions'
      }).that_notifies('Exec[export distribution precise]')
    end

    it do
      should contain_exec('export distribution precise').with({
        :command => "su -c 'reprepro -b /var/packages/localpkgs export precise' reprepro"
      })
    end

    it { should contain_file('/var/packages/localpkgs/tmp/precise') }
    it { should contain_cron('precise cron') }

    it { should_not contain_concat('/var/packages/localpkgs/conf/updates') }
  end

  context "With update set" do
    let(:title) { 'precise' }
    let :params do
      default_params.merge({
        :name     => 'precise',
        :codename => 'precise',
        :update   => true
      })
    end

  end

end
