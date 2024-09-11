require 'rbconfig'
require 'tmpdir'

Facter.add('ostempdir') do
  tmpdir = Dir.tmpdir
  tmpdir.gsub! '/', '\\' if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
  setcode { tmpdir }
end
