require 'spec_helper'

describe "uwsgi::app" do
    let (:facts) {{ :osfamily => 'Redhat' }}
    let (:title) { "testapp" }
    let (:params) {{ :environment_file => '/etc/settings' }}

    context "with osfamily => redhat" do
        let (:facts) {{ :osfamily => 'Redhat' }}
        it { should contain_class('uwsgi') }
        it { should contain_file('/etc/uwsgi/vassals.d/testapp.ini') }
    end

    context "with osfamily => debian" do
        let (:facts) {{ :osfamily => 'Debian' }}
        it { should contain_file('/etc/uwsgi/vassals.d/testapp.ini') }
    end

    it { should contain_uwsgi__app('testapp') }
    it { should contain_file('/etc/uwsgi/vassals.d/testapp.ini').with_content(/[uwsgi]/) }
    it { should contain_file('/etc/uwsgi/vassals.d/testapp.ini').with_content(/for-readline = \/etc\/settings/) }
end
