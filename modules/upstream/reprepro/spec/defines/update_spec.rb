require 'spec_helper'

describe 'reprepro::update' do

  let :default_params do
    {
      :basedir        => '/var/packages',
      :name           => 'lenny-backports',
      :suite          => 'lenny',
      :repository     => 'dev',
      :url            => 'http://backports.debian.org/debian-backports',
      :ignore_release => 'No'
    }
  end

  context "With default params" do
    let(:title) { 'lenny-backports' }
    let :params do default_params end

    fragment         = 'update-lenny-backports'
    target           = '/var/packages/dev/conf/updates'
    safe_name        = fragment.gsub(/[:\/\n]/, '_')
    safe_target_name = target.gsub(/[\/\n]/, '_')
    concatdir        = '/var/lib/puppet/concat'
    fragdir          = "#{concatdir}/#{safe_target_name}"

    it { should contain_class('reprepro::params') }
    it { should contain_class('concat::setup') }

    it do
      should contain_concat__fragment(fragment).with({
        :target => target
      })
    end

    # Check the template
    it { should contain_file("#{fragdir}/fragments/10_#{safe_name}").with_content(/Name: lenny-backports/) }
    it { should contain_file("#{fragdir}/fragments/10_#{safe_name}").with_content(/IgnoreRelease: #{default_params[:ignore_release]}/) }

  end
end
