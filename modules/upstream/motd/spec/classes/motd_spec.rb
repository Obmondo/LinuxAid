require 'spec_helper'

describe 'motd', :type => :class do

  describe 'On a non-linux system' do
    let(:facts) {{ :kernel => 'Unknown' }}
    it "should not fail" do
      expect do
        subject
      end.not_to raise_error()
    end
    it { should_not contain_file('/etc/motd') }
  end

  describe "On Linux - no ::domain" do
    let(:facts) {{
      :kernel => 'Linux',
      :operatingsystem => 'TestOS',
      :memoryfree => '1 KB',
      :domain => nil,
    }}
    context 'When ::domain is not present and a template has not been specified' do
      it { should contain_File('/etc/motd').with(
        :ensure => 'file',
        :backup => 'false',
        :content => "The operating system is TestOS\nThe free memory is 1 KB\n"
      )}
    end
  end

  describe "On Linux" do
    let(:facts) {{
      :kernel          => 'Linux',
      :operatingsystem => "TestOS",
      :memoryfree      => "1 KB",
      :domain          => "testdomain"
    }}
    context "When neither template or source are specified" do
      it { should contain_File('/etc/motd').with(
        :ensure  => 'file',
        :backup  => 'false',
        :content => "The operating system is TestOS\nThe free memory is 1 KB\nThe domain is testdomain\n"
        )
      }
    end

    context 'When both template and source are specified' do
      let(:params) { {
        :content => 'Hello!',
        :template => 'motd/spec.erb',
      } }
      it { should contain_File('/etc/motd').with(
        :ensure  => 'file',
        :backup  => 'false',
        :content => "Test Template for Rspec\n"
        )
      }
    end

    context 'When a source is specified' do
      let(:params) { {:content => 'Hello!' } }
      it { should contain_File('/etc/motd').with(
        :ensure  => 'file',
        :backup  => 'false',
        :content => "Hello!"
        )
      }
    end

    context "When an external template is specified" do
      let(:params) { { :template => 'motd/spec.erb' } }
      it { should contain_File('/etc/motd').with(
        :ensure  => 'file',
        :backup  => 'false',
        :content => "Test Template for Rspec\n"
        )
      }
    end
  end
end
