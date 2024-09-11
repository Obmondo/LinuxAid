#!/opt/puppetlabs/puppet/bin/ruby
require 'rubygems'
require 'facter'

$command = $process = nil

case Facter.value(:osfamily)
when 'RedHat'
  $command = "httpd"
  $process = "httpd"
when 'Debian'
  $command = "apache2ctl"
  $process = "apache2"
end

def obmondo_apache_monitor
  if system "pgrep #{$process} 2>/dev/null >/dev/null"
    invalid_domains = `/usr/sbin/#{$command} -D DUMP_VHOSTS 2>/dev/null | grep -vEi "alias|NameVirtualHost|configuration" | cut -d "(" -f 1 | awk '{print $NF}' | uniq`.split("\n")
    hostname = Facter.value(:hostname)
    invalid_domains.nil? ? false : invalid_domains.include?("zapache.#{hostname}")
  else
    false
  end
end

if __FILE__ == $0
  r = obmondo_apache_monitor
  exit r ? 0 : 1
end

Facter.add("obmondo_apache_monitor") do
  obmondo_apache_monitor
end
