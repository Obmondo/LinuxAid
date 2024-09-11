require 'spec_helper'

describe 'reprepro::pull' do

  let :default_params do
    {
      :basedir => '/var/packages',
    }
  end

  context "With default parameters" do
    let(:title) { 'lenny-backports' }
    let :params do
      default_params.merge({
        :name       => 'lenny-backports',
        :repository => 'localpkgs',
        :from       => 'dev'
      })
    end

    fragment         = 'pulls-lenny-backports'
    target           = '/var/packages/localpkgs/conf/pulls'
    safe_name        = fragment.gsub(/[:\/\n]/, '_')
    safe_target_name = target.gsub(/[\/\n]/, '_')
    concatdir        = '/var/lib/puppet/concat'
    fragdir          = "#{concatdir}/#{safe_target_name}"

    it { should contain_class('reprepro::params') }

    it do
      should contain_concat__fragment(fragment).with({
        :target => target
      })
    end

    # Check the template
    it { should contain_file("#{fragdir}/fragments/10_#{safe_name}").with_content(/Name: lenny-backports/) }
    it { should contain_file("#{fragdir}/fragments/10_#{safe_name}").with_content(/From: #{default_params[:from]}/) }

  end
end
