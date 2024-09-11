Facter.add(:varnishcliports) do
	confine :kernel => :linux
	ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
	setcode do
		varnishcliports = []
		result = %x{ps fuaxww | grep -i "varnishd.*vcl.-T" | grep -Ev "grep"}
		if $?.exitstatus == 0
			result.each do |port|
				varnishcliports.push($1) if port =~ /-T 127.0.0.1:([0-9]+) /
			end
		end
  	varnishcliports
	end
end
