require 'spec_helper'

describe 'reprepro::filterlist' do

  let :default_params do
    {
      :basedir    => '/var/packages',
      :repository => 'dev',
      :packages   => ['git install', 'git-email install'],
    }
  end

  context "With default basedir" do
    let(:title) { 'lenny-backports' }
    let :params do default_params end

    it { should contain_class('reprepro::params') }
    it { should contain_file('/var/packages/dev/conf/lenny-backports-filter-list') }
  end

  context "With defined basedir" do
    let(:title) { 'lenny-backports' }
    let :params do
      default_params.merge(
        {
          :basedir => '/foo/bar'
        }
      )
    end

    it { should contain_class('reprepro::params') }
    it { should contain_file('/foo/bar/dev/conf/lenny-backports-filter-list') }
  end

end
