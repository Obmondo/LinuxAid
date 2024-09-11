require 'puppet/provider/package'

Puppet::Type.type(:cpan).provide(:cpan, :parent => Puppet::Provider::Package ) do
	desc "Installation of perl modules from cpan"

	commands :cpanm => "/usr/bin/cpanm" if Puppet::FileSystem.exist? '/usr/bin/cpanm'
	commands :perldoc => "perldoc"

	# TODO add cpan as different way of installation.
	def create
		cpanm resource[:name]
	end

	def destroy
		cpanm('-U', '-f', resource[:name])
	end

	def exists?
		begin
			perldoc('-l', resource[:name])
			true
		rescue Puppet::ExecutionFailure => e
			false
		end
	end
end
