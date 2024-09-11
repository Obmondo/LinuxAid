require 'spec_helper'

describe 'bind::server::conf' do
	let (:title)  { '/etc/named.conf' }
	let (:params) { {
		:acls => { 
			'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ] 
		},
		:masters => {
			'mymasters' => ['192.0.2.1', '198.51.100.1']
		},
		:zones => {
			'example.com' => [
				'type master',
				'file "example.com"',
			],
			'example.org' => [
				'type slave',
				'file "slaves/example.org"',
				'masters { mymasters; }',
			],
		},
		:includes => [
			'/etc/myzones.conf',
		],
	} }

	it 'should generate the bind configuration' do
		expect { should contain_file ('/etc/named.conf')}
		content = catalogue.resource('file', '/etc/named.conf').send(:parameters)[:content]
        content.should_not be_empty
        content.should match('acl rfc1918')
        content.should match('masters mymasters')
        content.should match('zone "example.com"')
        content.should match('zone "example.org"')
        content.should match('include "/etc/myzones.conf"')
	end

end