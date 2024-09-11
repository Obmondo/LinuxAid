require 'spec_helper'

describe 'bind::server::file' do
	let(:title) { 'example.com' }
	let (:params) {{
		:source => 'puppet:///modules/bind/named.empty'
	}}

	it { should contain_file('/var/named/example.com') }
end