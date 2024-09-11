# lib/puppet/type/cpan.rb
Puppet::Type.newtype(:cpan) do
	
	@doc = "Manage the installation and uninstallation of perl libraries from cpan repository using cpanminus manager,
		you can pass your own local cpan repository. 

		Valid options :- 
		1. 'ensure' => present||absent 		# Present is the default options, absent will uninstall the perl libraries.
		2. 'version' => latest 			# Latest version of perl libraries will get installed, if you want you can pass the version number.
		3. 'environment' => undef 		# Pass the run time envrionment

		Example: 
			cpan { 'Text::ASCIITable' : ensure => present }
			cpan { 'Text::ASCIITable' : ensure => present, version => '1.0.1', enviornment => 'HOME=/tmp'} "

	ensurable do
		defaultvalues
		defaultto :present
	end

	newparam(:name, :namevar => true) do
		desc "Name of the Perl library"
	end
	
	newproperty(:version) do
		desc "Specify version number"
		validate do |value|
			fail("Invalid version #{value}") unless value =~ /^[0-9A-Za-z\.:-]+$/
		end
	end

#	newproperty(:environment) do
#		desc "Specify any runtime envrionment"
#	end
end
