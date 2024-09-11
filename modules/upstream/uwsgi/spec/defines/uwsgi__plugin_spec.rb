require 'spec_helper'

describe "uwsgi::plugin" do
    let (:title) { "datadogd" }
    let (:facts) do
        {
            :osfamily => 'Redhat'
        }
    end
    let (:params) {{ :url => "http://github.com/datadog/uwsgi.git" }}
    it { should contain_class('uwsgi') }
    it { should contain_uwsgi__plugin('datadogd') }
    it { should contain_exec('uwsgi --build-plugin http://github.com/datadog/uwsgi.git').with_cwd('/etc/uwsgi/plugins') }
end
